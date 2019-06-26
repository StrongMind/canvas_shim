module RequirementsService
  def self.apply_minimum_scores(context_module:, force: false)
    Commands::ApplyMinimumScores.new(context_module: context_module, force: force).call
  end

  def self.set_passing_threshold(type:, threshold:, edited:, id: 1)
    Commands::SetPassingThreshold.new(type: type, threshold: threshold, edited: edited, id: id).call
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

  def self.set_school_threshold_on_course(course:)
    Commands::SetSchoolThresholdOnCourse.new(course: course).call
  end
end