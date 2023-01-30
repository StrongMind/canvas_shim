DiscussionTopic.class_eval do
  after_commit -> { PipelineService.publish(self) }

  def is_excused?(user)
    self&.assignment&.is_excused?(user)
  end

  def graded_discussion?
    self.root_topic.nil? && self.type.nil? && self.assignment.present?
  end
end
