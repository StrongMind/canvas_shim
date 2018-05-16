module PipelineService
  module Serializers
    class Assignment
      KEY = 'IQQI1GysDSk8XdjZheKZ3eaa8Qu5J9ZfB2pZ8YMEVgWMvzXInpTv15Frh0GGEZ0l'

      def initialize(object:)
        @object = object
      end

      def call
        post
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

      def port
        '3000'
      end

      def headers
        { Authorization: "Bearer #{KEY}" }
      end

      def post
        http_client.get(
          endpoint, headers: headers
        ).parsed_response
      end

      def course_id
        object.course.id
      end

      def http_client
        HTTParty
      end

      def protocol
        return 'https://' if ENV['CANVAS_SSL'] == 'true'
        'http://'
      end
    end
  end
end
