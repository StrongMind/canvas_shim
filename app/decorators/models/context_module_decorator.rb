ContextModule.class_eval do
  after_save :assign_threshold
  after_commit -> { PipelineService.publish_as_v2(self, alias: 'module') }

  def assign_threshold
    if completion_requirements_was&.empty?
      RequirementsService.apply_minimum_scores(context_module: self, assignment_group_names: AssignmentGroup.passing_threshold_group_names)
    end
  end

  def get_assignment_threshold_overrides
    SettingsService.get_settings(object: 'course', id: self.course.try(:id))['threshold_overrides']
  end
end
