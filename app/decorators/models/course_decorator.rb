Course.class_eval do
  after_commit -> { PipelineService.publish(self) }

  def force_min_scores
    context_modules.each(&:force_min_score_to_requirements)
  end
end
