Submission.class_eval do
  after_commit :bust_context_module_cache

  def bust_context_module_cache
    if self.previous_changes.include?(:excused)
      touch_context_module
    end
  end

  def touch_context_module
    self&.assignment&.context_module_tags.each do |tag|
      tag.context_module.send_later_if_production(:touch)
    end
  end
end
