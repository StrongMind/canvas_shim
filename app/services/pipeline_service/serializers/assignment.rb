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

      def self.build_token
        Thread.new do
          ActiveRecord::Base.connection_pool.with_connection do
            PipelineService::Account.account_admin.access_tokens.create(
              developer_key: DeveloperKey.default,
              purpose: 'Pipeline API Access'
            )
          end
        end.value.full_token
      end

      def self.token
        token = Canvas.redis.get('PIPELINE_CANVAS_API_TOKEN')
        return token if token

        AccessToken.where(purpose: 'Pipeline API Access').delete_all

        result = build_token

        Canvas.redis.set('PIPELINE_CANVAS_API_TOKEN', result)
        result
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
        { Authorization: "Bearer #{self.class.token}" }
      end

      def fetch
        self.class.http_client.get(endpoint, headers: headers).parsed_response
      end

      def course_id
        object.course.id
      end

      def self.http_client
        HTTParty
      end

      def protocol
        return 'https://' if ENV['CANVAS_SSL'] == 'true'
        'http://'
      end
    end
  end
end
