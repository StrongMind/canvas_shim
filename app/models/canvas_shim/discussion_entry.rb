module CanvasShim
  module DiscussionEntry
    def set_unread_status
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

    def self.included(base)
      base.class_eval do
        after_save :set_unread_status
        after_find :set_unread_status
      end
    end
  end
end
