class DiscussionEntry
  alias_method :change_read_state_alias, :change_read_state
  after_save :set_unread_status
  after_find :set_unread_status

  def set_unread_status
    puts "***** SET UNREAD STATUS *****"
    topic = self.discussion_topic
    course = self.discussion_topic.course
    topic_microservice_endpoint = ENV['TOPIC_MICROSERVICE_ENDPOINT']
    api_key = ENV['TOPIC_MICROSERVICE_API_KEY']

    return unless topic_microservice_endpoint && api_key

    course.teachers.each do |teacher|
      endpoint = "#{topic_microservice_endpoint}/teachers/#{ENV['CANVAS_DOMAIN']}:#{teacher.id}/topics/#{topic.id}"

      if self.unread?(teacher)
        HTTParty.post(endpoint, headers: { "x-api-key": api_key })
      else
        HTTParty.delete(endpoint, headers: { "x-api-key": api_key })
      end
    end
  end

  def change_read_state(new_state, current_user = nil, opts = {})
    result = change_read_state_alias(new_state, current_user, opts)
    set_unread_status
    result
  end
end
