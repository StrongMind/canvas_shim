module PipelineService
  module Serializers
    class DiscussionTopic
      include Api
      include Api::V1::DiscussionTopics
      include Rails.application.routes.url_helpers

      Rails.application.routes.default_url_options[:host] = ENV['CANVAS_DOMAIN']

      def initialize(object:)
        @object = object
        @discussion_topic = ::DiscussionTopic.find(object.id)
      end

      def call
        return unless @discussion_topic.context_type == "Course"
        discussion_topics_api_json(
          [@discussion_topic],
          @discussion_topic.context,
          GradesService::Account.account_admin,
          nil
        ).first
      end

      def self.additional_identifier_fields
        [Models::Identifier.new(:context_id, alias: :course_id)]
      end

      private

      attr_reader :object

      def course_id
        ::DiscussionTopic.find(object.id).context_id
      end
    end
  end
end
