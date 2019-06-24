ContextModule.class_eval do
  after_save :assign_threshold
  after_commit -> { PipelineService.publish(self, alias: 'module') }

  def assign_threshold
    RequirementsService.apply_minimum_scores_to_unit(context_module: self)
  end
end
