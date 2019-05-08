module PipelineService
  module V2
    class Client
      URL = 'https://sqs.us-west-2.amazonaws.com/448312246740/canvas-life-cycle'
      REGION = 'us-west-2'
      include Singleton

      def initialize
        @sqs = Aws::SQS::Client.new(region: REGION)
      end
      
      def self.publish(payload)
        instance.publish(payload)
      end

      def publish(payload)
        @sqs.send_message(queue_url: URL, message_body: payload.to_json)
      end
    end
  end
end