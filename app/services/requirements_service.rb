module RequirementsService
  def self.apply_minimum_scores(context_module:, force: false)
    Commands::ApplyMinimumScores.new(context_module: context_module, force: force).call
  end

  def self.set_new_threshold(type:, threshold:, edited:)
    Commands::SetNewThreshold.new(type: type, threshold: threshold, edited: edited).call
  end

  def self.enable_threshold_permissions(course_thresholds:, post_enrollment:, module_editing:)
    Commands::EnableThresholdPermissions.new(
      course_thresholds: course_thresholds,
      post_enrollment: post_enrollment,
      module_editing: module_editing,
    ).call
  end
end