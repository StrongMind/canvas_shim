module Api::V1::DiscussionTopics
  def discussion_topics_api_json(topics, context, user, session)
    topics.map { |topic| {"id" => topic.id} }
  end
end