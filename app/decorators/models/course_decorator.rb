Course.class_eval do
  has_many :active_students, -> {
      where("enrollments.workflow_state NOT IN ('rejected', 'deleted', 'inactive', 'invited') AND enrollments.type = 'StudentEnrollment'").preload(:user)
    }, class_name: 'Enrollment'
  has_many :active_or_invited_students, -> {
      where("enrollments.workflow_state NOT IN ('rejected', 'deleted', 'inactive') AND enrollments.type = 'StudentEnrollment'").preload(:user)
    }, class_name: 'Enrollment'

  before_create :set_course_start_time_from_school
  after_commit -> { PipelineService.publish_as_v2(self) }
  after_create -> { RequirementsService.set_school_thresholds_on_course(course: self) }

  TAB_SNAPSHOT = 18

  class << self
    def strongmind_default_tabs
      default_tabs = instructure_default_tabs
      settings_tab = default_tabs.pop

      default_tabs.push(
        {
          :id => TAB_SNAPSHOT,
          :label => t('#tabs.snapshot', "Snapshot"),
          :css_class => 'course-snapshot',
          :href => :course_snapshot_path,
          :screenreader => t('#tabs.course_snapshot', "Snapshot")
        }
      )

      default_tabs.push(settings_tab)
    end

    alias_method :instructure_default_tabs, :default_tabs
    alias_method :default_tabs, :strongmind_default_tabs
  end

  def force_min_scores(assignment_group_names:)
    context_modules.each do |cm|
      RequirementsService.apply_minimum_scores(context_module: cm, force: true, assignment_group_names: assignment_group_names)
    end
  end

  def no_active_students?
    active_students.count.zero?
  end

  def average_score
    course_scores = active_students.map do |active|
      active.scores.first.try(:current_score).to_f
    end

    course_scores.reduce(&:+).to_f / working_denominator(course_scores)
  end

  def needs_grading_count
    assignments.map(&:needs_grading_count).reduce(&:+).to_i
  end

  def get_relevant_alerts_count(user)
    return unless user
    AlertsService::Client.course_teacher_alerts(
      course_id: id,
      teacher_id: user.id,
    ).payload.size
  end

  def get_accesses_by_hour
    start_at = 6.days.ago.in_time_zone(time_zone_name).beginning_of_day
    query = "url NOT ILIKE ? AND user_id IN (?) AND created_at >= ?"
    as_ids = active_students.pluck(:user_id)
    api_match = "%/api/%"

    accesses = page_views.where(
      "#{query} OR #{query} AND updated_at >= ?",
      api_match, as_ids,
      start_at, api_match, as_ids,
      start_at, start_at
    )

    accessed_hours = accesses.group_by_hour(:created_at).count
    #168 hours per week
    (0..167).map do |hour|
      access_time = start_at + hour.hours
      count = accessed_hours[access_time] || 0
      {access_time.in_time_zone(time_zone_name) => scale_count(count)}
    end
  end

  def calculate_progress(student, cached: false)
    cp = CourseProgress.new(self, student.user)
    req_count = cp.requirement_count.zero? ? 1 : cp.requirement_count(cached: cached)
    (cp.requirement_completed_count(cached: cached).to_f / req_count.to_f) * 100
  end

  def get_relevant_student_alerts_count(student)
    return unless student
    AlertsService::Client.course_student_alerts(
      course_id: id,
      student_id: student.id,
    ).payload.size
  end
  
  def set_course_start_time_from_school
    @course_start_time = SettingsService.get_settings(object: 'school', id: 1)['course_start_time']
    self.start_at = DateTime.now.change({ hour: @course_start_time.split(":")[0].to_i, min: @course_start_time.split(":")[1].to_i })
  end

  def online_user_count
    count = 0
    self.enrollments.where(workflow_state: 'active').each do |en|
      count = count + 1 if en.user.is_online?
    end
    count
  end

  def expired_announcements
    filtered_announcements(expired_announcements_array)
  end

  def non_expired_announcements
    filtered_announcements(non_expired_announcements_array)
  end

  def snapshot_students
    active_students.eager_load(:user)
    .pluck(:id, :user_id, 'users.name').map do |stu_arr|
      stu_arr.concat(get_snapshot_sis_ids(stu_arr))
    end
  end

  def has_no_requirements?
    context_modules.none? { |cm| cm.completion_requirements.any? }
  end

  def update_context_module_completion_reqs
    self.context_modules.each do |context_module|
      RequirementsService.apply_minimum_scores(context_module: context_module, assignment_group_names: AssignmentGroup.passing_threshold_group_names)
    end
  end
  handle_asynchronously :update_context_module_completion_reqs

  private
  def filtered_announcements(filter)
    active_announcements.where("discussion_topics.id IN (?)", filter.map(&:id))
  end

  def expired_announcements_array
    active_announcements.select(&:is_expired?)
  end

  def non_expired_announcements_array
    active_announcements.reject(&:is_expired?)
  end

  def time_zone_name
    time_zone.name
  end

  def working_denominator(arr)
    arr.none? ? 1 : arr.size
  end

  def scale_count(count)
    return 0 if no_active_students?
    return count if SettingsService.get_settings(id: 1, object: 'school')['unweighted_course_access_report']
    enrs = active_students.size
    return 10 if count >= enrs * 10
    count.divmod(enrs).first
  end

  def get_snapshot_sis_ids(stu_arr)
    Pseudonym.select(:user_id, :sis_user_id)
    .where(user_id: stu_arr.second).pluck(:sis_user_id)
  end
end
