Submission.class_eval do
  after_commit :bust_context_module_cache
  after_commit -> { PipelineService::V2.publish(self) }

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
