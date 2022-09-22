ContextModule.class_eval do
  after_save :assign_threshold
  # after_commit -> { PipelineService.publish_as_v2(self, alias: 'module') }

  def assign_threshold
    if completion_requirements_was&.empty?
      RequirementsService.apply_minimum_scores(context_module: self)
    end
  end
end
