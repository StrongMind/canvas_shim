Submission.class_eval do
  after_commit :bust_context_module_cache
  after_commit :publish_to_pipeline

  def publish_to_pipeline
    if SettingsService.get_settings(object: :school, id: 1)['v2_submissions']
      PipelineService::V2.publish(self)
    else
      PipelineService.publish(self)
    end
  end

  def bust_context_module_cache
    if self.previous_changes.include?(:excused)
      touch_context_module
    end
  end

  def touch_context_module
    tags = self&.assignment&.context_module_tags || []

    tags.each do |tag|
      tag.context_module.send_later_if_production(:touch)
    end
  end
end
