module PipelineService
  module V2
    class Client
      REGION = 'us-west-2'
      include Singleton

      def initialize
        @url = SettingsService.get_settings(object: 'school', id: 1)['pipeline_sqs_url']
        @sqs = Aws::SQS::Client.new(region: REGION)
      end
      
      def self.publish(payload)
        instance.publish(payload)
      end

      def publish(payload)
        @sqs.send_message(queue_url: @url, message_body: payload.to_json)
      end
    end
  end
end