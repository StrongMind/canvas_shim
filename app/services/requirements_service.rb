module RequirementsService
  def self.apply_minimum_scores(context_module:, force: false)
    apply_assignment_min_scores(context_module: context_module, force: force)
    apply_unit_exam_min_scores(context_module: context_module, force: force)
  end

  def self.apply_assignment_min_scores(context_module:, force: false)
    Commands::ApplyAssignmentMinScores.new(context_module: context_module, force: force).call
  end

  def self.apply_unit_exam_min_scores(context_module:, force: false)
    Commands::ApplyUnitExamMinScores.new(context_module: context_module, force: force).call
  end

  def self.force_min_scores(course:)
    Commands::ForceMinScores.new(course: course).call
  end

  def self.set_passing_threshold(type:, threshold:, edited:, id: 1, exam: false)
    Commands::SetPassingThreshold.new(
      type: type,
      threshold: threshold,
      edited: edited,
      id: id,
      exam: exam,
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

  def self.add_unit_item_with_min_score(context_module:, content_tag:)
    Commands::AddUnitItemWithMinScore.new(
      context_module: context_module,
      content_tag: content_tag,
    ).call
  end

  def self.set_school_thresholds_on_course(course:)
    Commands::SetSchoolThresholdsOnCourse.new(course: course).call
  end

  def self.get_raw_passing_threshold(type:, id: 1, exam: false)
    Queries::GetPassingThreshold.new(type: type, id: id, exam: exam).call
  end

  def self.get_passing_threshold(type:, id: 1, exam: false)
    get_raw_passing_threshold(type: type, id: id, exam: exam).to_f
  end

  def self.get_course_assignment_passing_threshold?(context)
    get_raw_passing_threshold(type: :course, id: context.try(:id))
  end

  def self.get_course_exam_passing_threshold?(context)
    get_raw_passing_threshold(type: :course, id: context.try(:id), exam: true)
  end

  def self.course_has_set_threshold?(context)
    get_course_assignment_passing_threshold?(context) ||
    get_course_exam_passing_threshold?(context)
  end

  def self.is_unit_exam?(content_tag:)
    Queries::FindUnitExam.new(content_tag: content_tag).call
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

  def self.reset_requirements(context_module:, exam: false)
    Commands::ResetRequirements.new(context_module: context_module, exam: exam).call
  end
end
