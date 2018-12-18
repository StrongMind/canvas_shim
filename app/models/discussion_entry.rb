class DiscussionEntry
  after_save :set_unread_status
  after_find :set_unread_status

  def set_unread_status
    topic = self.discussion_topic
    course = self.discussion_topic.course
    topic_microservice_domain = ENV['TOPIC_MICROSERVICE_DOMAIN']
    api_key = ENV['TOPIC_MICROSERVICE_API_KEY']

    return unless topic_microservice_domain && api_key


    course.teachers.each do |teacher|
      endpoint = "https://#{topic_microservice_domain}/teachers/#{ENV['CANVAS_DOMAIN']}:#{teacher.id}/topics/#{topic.id}"

      if self.unread?(teacher)
        HTTParty.post(endpoint, headers: { "x-api-key": api_key })
      else
        HTTParty.delete(endpoint, headers: { "x-api-key": api_key })
      end
    end
  end
end
