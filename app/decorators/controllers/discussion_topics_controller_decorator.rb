DiscussionTopicsController.class_eval do
  def strongmind_index
    @discussions = @context&.discussion_topics
    js_env(excused_discussions: excused_discussion_topics)
    instructure_index
  end

  alias_method :instructure_index, :index
  alias_method :index, :strongmind_index

  private
  def excused_discussion_topics
    return [] unless topics_available?
    @discussions.map do |topic|
      topic.is_excused?(@current_user) ? "##{topic.id}_discussion_content" : nil
    end.compact
  end

  def topics_available?
    @discussions && @context.is_a?(Course) && @context.user_is_student?(@current_user)
  end
end
