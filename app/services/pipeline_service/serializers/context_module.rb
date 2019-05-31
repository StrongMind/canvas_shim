module PipelineService
  module Serializers
    class ContextModule
      def initialize(object:)
        @object = object
        @context_module = ::ContextModule.find(@object.id)
        @course_id = @context_module.context_id
      end

      def call
        fetch
      end

      def self.additional_identifier_fields
        [ Models::Identifier.new(:context_id, alias: :course_id) ]
      end

      private

      attr_reader :object

      def domain
        ENV['CANVAS_DOMAIN']
      end

      def endpoint
        [
          protocol, domain, ':', port,
          "/api/v1/courses/#{@course_id}/modules/#{@object.id}"
        ].join('')
      end

      def use_ssl?
        ENV['CANVAS_SSL'] == 'true'
      end

      def port
        return '3000' if Rails.env == 'development'
        return '443' if use_ssl?
        '80'
      end

      def headers
        { Authorization: "Bearer #{ENV['STRONGMIND_INTEGRATION_KEY']}" }
      end

      def fetch
        PipelineService::HTTPClient.get(endpoint, headers: headers).parsed_response
      end

      def course_id
        ::DiscussionTopic.find(object.id).context_id
      end

      def protocol
        return 'https://' if use_ssl?
        'http://'
      end
    end
  end
end
