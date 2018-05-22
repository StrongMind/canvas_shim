module PipelineService
  module Serializers
    class Assignment
      def initialize(object:)
        @object = object
      end

      def call
        fetch
      end

      private

      attr_reader :object

      def domain
        ENV['CANVAS_DOMAIN']
      end

      def endpoint
        [
          protocol,
          domain,
          ':',
          port,
          '/api/v1/courses/',
          course_id,
          '/assignments/',
          object.id
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
        { Authorization: "Bearer #{PipelineService::TokenBuilder.build}" }
      end

      def fetch
        PipelineService::HTTPClient.get(endpoint, headers: headers).parsed_response
      end

      def course_id
        object.course.id
      end

      def protocol
        return 'https://' if use_ssl?
        'http://'
      end
    end
  end
end
