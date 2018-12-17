class DiscussionEntry
  after_save :set_unread_status

  def set_unread_status
    raise 'boom'
    topic = self.discussion_topic
    course = self.discussion_topic.course
    topic_microservice_domain = ENV['TOPIC_MICROSERVICE_DOMAIN']
    return unless topic_microservice_domain

    course.teachers.each do |teacher|
      endpoint = "http://#{topic_microservice_domain}/teachers/#{teacher.id}/topics/#{topic.id}"
      if self.unread?(teacher)
        HTTParty.post(endpoint)
      else
        HTTParty.delete(endpoint)
      end
    end
  end
end
