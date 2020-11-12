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

      def named_context_url(context, name, *opts)
        if context.is_a?(UserProfile)
          name = name.to_s.sub(/context/, "profile")
        else
          klass = context.class.base_class
          name = name.to_s.sub(/context/, klass.name.underscore)
          opts.unshift(context)
        end
        opts.push({}) unless opts[-1].is_a?(Hash)
        include_host = opts[-1].delete(:include_host)
        if !include_host
          opts[-1][:host] = context.host_name rescue nil
          opts[-1][:only_path] = true unless name.end_with?("_path")
        end
        self.send name, *opts
      end
    end
  end
end
