module RequirementsService
  def self.apply_minimum_scores(context_module:, force: false, assignment_group_names:)
    apply_assignment_group_min_scores(context_module: context_module, force: force, assignment_group_names: assignment_group_names)
  end

  def self.apply_assignment_group_min_scores(context_module:, force: false, assignment_group_names:)
    assignment_group_names.each do |group_name|
      Commands::ApplyAssignmentGroupMinScores.new(context_module: context_module, force: force, assignment_group_name: group_name).call
    end
  end

  def self.force_min_scores(course:, assignment_group_names: AssignmentGroup.passing_threshold_group_names)
    Commands::ForceMinScores.new(course: course, assignment_group_names: assignment_group_names).call
  end

  def self.set_passing_threshold(type:, threshold:, edited:, id: 1, assignment_group_name: nil)
    return unless assignment_group_name
    Commands::SetPassingThreshold.new(
      type: type,
      threshold: threshold,
      edited: edited,
      id: id,
      assignment_group_name: assignment_group_name
    ).call
  end

  def self.set_threshold_permissions(course_thresholds:, post_enrollment:, module_editing:)
    Commands::SetThresholdPermissions.new(
      course_thresholds: course_thresholds,
      post_enrollment: post_enrollment,
      module_editing: module_editing,
    ).call
  end

  def self.add_threshold_overrides(context_module:, requirements:)
    Commands::AddThresholdOverrides.new(
      context_module: context_module,
      requirements: requirements,
    ).call
  end

  def self.add_unit_item_with_passing_threshold(context_module:, content_tag:, assignment_group_name:)
    Commands::AddUnitItemWithPassingThreshold.new(
      context_module: context_module,
      content_tag: content_tag,
      assignment_group_name: assignment_group_name
    ).call
  end

  def self.set_school_thresholds_on_course(course:)
    Commands::SetSchoolThresholdsOnCourse.new(course: course).call
  end

  def self.get_raw_passing_threshold(type:, id: 1, assignment_group_name: nil)
    Queries::GetPassingThreshold.new(type: type, id: id, assignment_group_name: assignment_group_name).call
  end

  def self.get_passing_threshold(type:, id: 1, assignment_group_name: nil)
    return unless assignment_group_name
    get_raw_passing_threshold(type: type, id: id, assignment_group_name: assignment_group_name).to_f
  end

  def self.get_course_assignment_passing_threshold?(context)
    get_raw_passing_threshold(type: :course, id: context.try(:id))
  end

  def self.get_course_exam_passing_threshold?(context)
    get_raw_passing_threshold(type: :course, id: context.try(:id), assignment_group_name: nil)
  end

  def self.get_assignment_group_passing_thresholds(context:, assignment_group_names: AssignmentGroup.passing_threshold_group_names)
    type = context&.class&.to_s&.downcase == 'pipelineservice::models::noun' ? context.noun_class : context&.class
    thresholds = {}
    assignment_group_names.each do |group_name|
      thresholds[group_name] = get_passing_threshold(type: type&.to_s&.downcase, id: context.try(:id), assignment_group_name: group_name).to_f
    end
    thresholds
  end

  def self.course_has_set_threshold?(context:, assignment_group_names: assignment_group_names)
    thresholds = get_assignment_group_passing_thresholds(context: context, assignment_group_names: assignment_group_names)
    thresholds.any?
  end

  def self.course_threshold_setting_enabled?
    SettingsService.get_settings(object: :school, id: 1)['course_threshold_enabled']
  end

  def self.post_enrollment_thresholds_enabled?
    SettingsService.get_settings(object: :school, id: 1)['enable_post_enrollment_threshold_updates']
  end

  def self.disable_module_editing_on?
    SettingsService.get_settings(object: :school, id: 1)['disable_module_editing']
  end

  def self.module_editing_enabled?
    !RequirementsService.disable_module_editing_on?
  end

  def self.strip_overrides(course)
    SettingsService.update_settings(
      object: 'course',
      id: course.try(:id),
      setting: 'threshold_overrides',
      value: false
    )
  end

  def self.reset_requirements(context_module:, assignment_group_name:)
    Commands::ResetRequirements.new(context_module: context_module, assignment_group_name: assignment_group_name).call
  end

  def self.set_third_party_requirements(course:)
    if course && course.has_no_requirements?
      course.context_modules.each do |context_module|
        Commands::DefaultThirdPartyRequirements.new(context_module: context_module).call
      end
    end
  end

  def self.percentify_min_score(content_tag:, passing_threshold:)
    Commands::MinScorePercentifier.new(
      content_tag: content_tag,
      passing_threshold: passing_threshold
    ).call
  end
end
