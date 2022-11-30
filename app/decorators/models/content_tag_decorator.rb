ContentTag.class_eval do
  after_commit -> do
    return if self.content_type == "LearningOutcome"
    PipelineService::V2.publish self
  end
  after_commit -> do
    return unless course
    return if self.content_type == "LearningOutcome"
    PipelineService.publish PipelineService::Nouns::ModuleItem.new(self)
  end

  # after_save :call_requirements_service #TODO: add a check, why are we saving?

  def call_requirements_service
    if self.content.assignment.present?
      assignment_group = self.content.assignment.assignment_group.downcase.gsub(/\s/, "_")
      threshold_type = "#{assignment_group}_score_threshold"
      RequirementsService.add_unit_item_with_min_score(context_module: self.context_module, content_tag: self, threshold_type: threshold_type)
    end
  end
end
