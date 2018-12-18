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
      endpoint = "http://#{topic_microservice_domain}/teachers/#{teacher.id}/topics/#{topic.id}?api_key=#{}"
      if self.unread?(teacher)
        HTTParty.post(endpoint)
      else
        HTTParty.delete(endpoint)
      end
    end
  end
end
