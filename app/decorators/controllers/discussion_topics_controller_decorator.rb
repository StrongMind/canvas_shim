DiscussionTopicsController.class_eval do
  def strongmind_index
    instructure_index
    js_env(excused_discussions: excused_discussion_topics)
  end

  alias_method :instructure_index, :index
  alias_method :index, :strongmind_index

  private
  def excused_discussion_topics
    return [] unless topics_available?
    @topics.map do |topic|
      return nil unless topic.is_excused?(@current_user)
      "##{id}_discussion_content"
    end.compact
  end

  def topics_available?
    @topics && @context.is_a?(Course) && @context.user_is_student?(@current_user)
  end
end
