ContextModulesController.class_eval do
  def strongmind_update
    @module = @context.context_modules.not_deleted.find(params[:id])
    add_threshold_overrides if can_add_threshold_overrides?
    instructure_update
  end

  alias_method :instructure_update, :update
  alias_method :update, :strongmind_update

  def strongmind_add_item
    instructure_add_item
    return unless gradeable_tag_type? && course_has_set_threshold?
    add_threshold_to_module
  end

  alias_method :instructure_add_item, :add_item
  alias_method :add_item, :strongmind_add_item

  def strongmind_item_redirect
    if @context && @current_user && course_has_set_threshold?
      course_progress = CourseProgress.new(@context, @current_user)
      @assignment = course_progress.try(&:current_content_tag).try(&:assignment)
      submission = @assignment ? @assignment.submissions.find_by(user: @current_user) : nil
      if @assignment && submission
        versions = submission.versions
        lti_latest = versions.find { |version| version.yaml && YAML.load(version.yaml)["grader_id"].to_i < 0 }
        attempt_number = YAML.load(lti_latest.yaml)["attempt"] if lti_latest

        if attempt_number
          max_attempts = find_max_attempts
          @maxed_out = (attempt_number >= max_attempts) if max_attempts
        end
      end
    end

    instructure_item_redirect
  end

  alias_method :instructure_item_redirect, :item_redirect
  alias_method :item_redirect, :strongmind_item_redirect

  private
  def gradeable_tag_type?
    %w{Assignment DiscussionTopic Quizzes::Quiz}.include?(@tag.content_type)
  end

  def add_threshold_to_module
    @module.completion_requirements << {:id => @tag.id, :type => "min_score", :min_score => score_threshold}
    @module.update_column(:completion_requirements, @module.completion_requirements)
  end

  def can_add_threshold_overrides?
    course_has_set_threshold? && module_editing_enabled? &&
    context_module_params[:completion_requirements] && authorized_action(@module, @current_user, :update)
  end

  def add_threshold_overrides
    @changed_reqs = []
    context_module_params[:completion_requirements].each do |k, v|
      requirement = @module.completion_requirements.find {|req| req[:id] == k.to_i }
      if requirement && changed_requirement?(v, requirement)
        @changed_reqs << requirement[:id]
      end
    end
    send_overrides_to_settings
  end

  def send_overrides_to_settings
    @all_reqs = conjoin_threshold_overrides(@changed_reqs)
    @all_reqs = @all_reqs.blank? ? false : @all_reqs.join(",")
    SettingsService.update_settings(
      object: 'course',
      id: @context.id,
      setting: 'threshold_overrides',
      value: @all_reqs
    )
  end

  def get_threshold_overrides
    @threshold_overrides ||= SettingsService.get_settings(object: :course, id: @context.try(:id))['threshold_overrides']
  end

  def conjoin_threshold_overrides(new_overrides)
    if get_threshold_overrides
      current_overrides = get_threshold_overrides.split(",")
      return current_overrides unless new_overrides.any?
      current_overrides.concat(new_overrides).uniq
    elsif new_overrides.any?
      new_overrides
    else
      []
    end
  end

  def changed_requirement?(param_requirement, current_requirement)
    param_requirement["type"] != current_requirement[:type] ||
    (current_requirement[:min_score] && param_requirement[:min_score].to_f != current_requirement[:min_score])
  end

  def find_max_attempts
    return unless @assignment.migration_id
    migration_id = @assignment.migration_id

    value = SettingsService.get_settings(
      object: 'assignment',
      id: migration_id
    )["max_attempts"]

    return unless value

    student_attempts = SettingsService.get_settings(
      object: 'student_assignment',
      id: {assignment_id: @assignment.id, student_id: @current_user.try(:id)}
    )['max_attempts']

    student_attempts ? student_attempts.to_i : value.to_i
  end
end
