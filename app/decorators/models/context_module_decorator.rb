ContextModule.class_eval do
  after_save :assign_threshold
  after_commit -> { PipelineService.publish(self, alias: 'module') }

  def assign_threshold
    RequirementsService.apply_minimum_scores_to_unit(context_module: self)
  end

  def force_min_score_to_requirements
    RequirementsService.apply_minimum_scores_to_unit(context_module: self, force: true)
  end
end
