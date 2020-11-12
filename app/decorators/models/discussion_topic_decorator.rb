DiscussionTopic.class_eval do
  after_commit -> { PipelineService.publish_as_v2(self) }

  def is_excused?(user)
    self&.assignment&.is_excused?(user)
  end
end