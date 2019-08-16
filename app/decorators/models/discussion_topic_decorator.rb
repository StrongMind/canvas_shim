DiscussionTopic.class_eval do
  after_commit -> { PipelineService.publish(self) }

  def is_excused?(user)
    self&.assignment&.is_excused?(user)
  end
end