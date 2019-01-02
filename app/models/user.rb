class User
  def get_teacher_unread_discussion_topics
    topic_microservice_endpoint = ENV['TOPIC_MICROSERVICE_ENDPOINT']
    api_key = ENV['TOPIC_MICROSERVICE_API_KEY']
    return {} unless topic_microservice_endpoint && api_key
    return {} if self.enrollments.where(type: 'TecherEnrollment').empty?
    endpoint = "#{topic_microservice_endpoint}/teachers/#{ENV['CANVAS_DOMAIN']}:#{self.id}/topics/"
    ret = HTTParty.get(endpoint, headers: { "x-api-key": api_key })
    ret.body
  end
end