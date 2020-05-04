User.class_eval do
  validate :validate_identity, :on => :create
  after_commit -> { PipelineService::V2.publish self }

  # Submissions must be excused upfront else once the first requirement check happens
  # the all_met condition will fail on submissions not being excused yet
  #
  # content_tag - where we want to place them
  # context_module - module of the place we want to place them
  def custom_placement_at(content_tag)
    context_module         = content_tag.context_module
    course                 = context_module.context
    new_placement_position = content_tag.position - 1

    # get 'lower' module units in Course
    bypass_modules = course.context_modules
                           .where('position < ?', context_module.position)
                           .order(position: :asc)

    # get 'lower' content tags within same context_module as where we're dropping user
    bypass_tags = context_module.content_tags
                  .active
                  .where('position <= ?', new_placement_position)
                  .order(position: :asc)

    # exclude any submissions requirements
    bypass_modules.each do |bypass_module|
      bypass_module.content_tags
                   .active
                   .order(position: :asc).each do |tag|

        exclude_submissions(tag)
        bypass_module.touch
      end
    end

    # exclude any submissions requirements
    bypass_tags.each do |tag|
      exclude_submissions(tag)
    end

    # force progression requirements of lower modules
    bypass_modules.each do |bypass_module|
      progression = bypass_module.find_or_create_progression(self) # self is user
      progression.update_columns requirements_met: bypass_module.completion_requirements,
                                 evaluated_at: (bypass_module.updated_at - 1.second),
                                 current: false # mark as outdated # TODO change back to false

      progression.reload.evaluate!
      bypass_module.touch
      sleep(Rails.env.production? ? 5 : 1)
    end

    # force progression requirements of lower tags in new placements context_module
    bypass_tags_context_module = context_module

    return if bypass_tags_context_module.nil?

    requirements_of_bypass_tags = bypass_tags.map do |tag|
      bypass_tags_context_module.completion_requirements.find do |req|
        req[:id] == tag.id
      end
    end.compact

    # puts '*** requirements_of_bypass_tags ***'
    # puts requirements_of_bypass_tags

    progression = bypass_tags_context_module.find_or_create_progression(self) # self is user
    progression.update_columns requirements_met: requirements_of_bypass_tags,
                               evaluated_at: (bypass_tags_context_module.updated_at - 1.second),
                               current: false # mark as outdated

    progression.reload.evaluate!
    bypass_tags_context_module.touch

    AssignmentOverrideStudent.where(user_id: self.id, assignment_id: course.assignment_ids).each(&:destroy!) # run through each as we want callbacks to fire
    sleep(Rails.env.production? ? 5 : 1)
  end

  def timezone_name
    self.try(:time_zone).try(:tzinfo).try(:name) || self.account.try(:time_zone).try(:tzinfo).try(:name) || Time.zone.name
  end

  def exclude_submissions(tag)
    tag.context_module.completion_requirements.each do |req|
      next unless req[:id] == tag.id

      subs = []

      # Things that can have assignments, i.e. Quiz, Discussion Topic, etc?
      if tag&.content&.respond_to? :assignment
        subs = tag&.content&.assignment&.submissions&.where(user_id: self.id) || []

      elsif tag&.content&.respond_to? :submissions # Assignment
        subs = tag&.content&.submissions&.where(user_id: self.id) || []
      end

      subs.each do |sub|
        sub.update_column :excused, true
      end
    end
  end

  def get_teacher_unread_discussion_topics(course)
    topic_microservice_endpoint = ENV['TOPIC_MICROSERVICE_ENDPOINT']
    api_key = ENV['TOPIC_MICROSERVICE_API_KEY']

    return {} unless topic_microservice_endpoint && api_key
    return {} if self.enrollments.where(type: 'TeacherEnrollment').empty?

    endpoint = "#{topic_microservice_endpoint}/teachers/#{ENV['CANVAS_DOMAIN']}:#{self.id}/topics/"
    ret      = HTTParty.get(endpoint, headers: { "x-api-key": api_key })

    return {} unless ret.code == 200

    ids = JSON.parse(ret.body).map(&:to_i)

    Assignment.joins(:discussion_topic).where('discussion_topics.id' => ids).where('context_id' => course.id)
  end

  def recent_feedback_with_wrap(opts={})
    filter_feedback(recent_feedback_without_wrap(opts))
  end

  def is_online?
    cache_key = "#{self.id}/last_access_time"
    last_access_time = Rails.cache.read(cache_key)
    current_time = Time.now.utc
    return true if last_access_time && last_access_time > current_time - 5.minutes
    false
  end

  alias_method :recent_feedback_without_wrap, :recent_feedback
  alias_method :recent_feedback, :recent_feedback_with_wrap


  def add_observee(observee)  
    user_observees.create_or_restore(user_id: observee.id) unless has_observee?(observee)
  end

  def has_observee?(observee)
    user_observees.active.where(user_id: observee.id).exists?
  end

  private

  def filter_feedback(submissions)
    submissions.select { |sub| sub.submission_comments.any? || (sub.grader_id && sub.grader_id > GradesService::Account.account_admin.try(:id)) }
  end

  def access_token
    @access_token ||= HTTParty.post(
      'https://devlogin.strongmind.com/connect/token',
      :body => "grant_type=client_credentials&scope=identity_server_api.full_access",
      :headers => {
        'Content-Type' => 'application/x-www-form-urlencoded',
        'Authorization' => "Basic #{SettingsService.get_settings(object: 'school', id: 1)['identity_basic_auth']}"
      }
    ).parsed_response["access_token"]
  end

  def validate_identity
    unless access_token
      return errors.add(:name, "invalid identity response")
    end

    identity_create = HTTParty.post(
      'devlogin.strongmind.com/api/accounts/withProfile',
      :body => {
        "Username" => name,
        "Email" => email,
        "SendPasswordResetEmail": true
      }.to_json,
      :headers => {
        'Content-Type' => 'application/json',
        'Authorization' => "Bearer #{access_token}"
      })

    unless identity_create.success?
      errors.add(:name, "invalid identity response")
    end
  end
end
