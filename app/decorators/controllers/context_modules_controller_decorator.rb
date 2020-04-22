ContextModulesController.class_eval do
  def strongmind_update
    @module = @context.context_modules.not_deleted.find(params[:id])

    if can_add_threshold_overrides?
      RequirementsService.add_threshold_overrides(
        context_module: @module,
        requirements: context_module_params[:completion_requirements]
      )
    end

    instructure_update
  end

  alias_method :instructure_update, :update
  alias_method :update, :strongmind_update

  def strongmind_add_item
    instructure_add_item
    RequirementsService.add_unit_item_with_min_score(context_module: @module, content_tag: @tag)
  end

  alias_method :instructure_add_item, :add_item
  alias_method :add_item, :strongmind_add_item

  # def strongmind_item_redirect
  #   if @context.is_a?(Course) && @context.user_is_student?(@current_user) && RequirementsService.course_has_set_threshold?(@context)
  #     course_progress = CourseProgress.new(@context, @current_user)
  #     @assignment = course_progress.try(&:current_content_tag).try(&:assignment)
  #     submission = @assignment.submissions.find_by(user: @current_user) if @assignment

  #     if @assignment && submission
  #       lti_latest = submission.versions.find { |version| version.yaml && YAML.load(version.yaml)["grader_id"].to_i < 0 }
  #       attempt_number = YAML.load(lti_latest.yaml)["attempt"] if lti_latest

  #       if attempt_number
  #         max_attempts = find_max_attempts
  #         @maxed_out = (attempt_number >= max_attempts) if max_attempts
  #       end
  #     end
  #   end

  #   instructure_item_redirect
  # end

  # alias_method :instructure_item_redirect, :item_redirect
  # alias_method :item_redirect, :strongmind_item_redirect

  private

  def can_add_threshold_overrides?
    RequirementsService.course_has_set_threshold?(@context) && RequirementsService.module_editing_enabled? &&
    context_module_params[:completion_requirements] && authorized_action(@module, @current_user, :update)
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
