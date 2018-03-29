module PipelineService
  module Commands
    class Send
      DEBUG_VERSION=1
      attr_reader :message
      MESSAGE_NAME = 'enrollment'
      SOURCE       = 'canvas'

      def initialize(args)
        @host              = ENV['PIPELINE_ENDPOINT']
        @username          = ENV['PIPELINE_USER_NAME']
        @password          = ENV['PIPELINE_PASSWORD']
        @domain_name       = ENV['CANVAS_DOMAIN']

        raise 'Missing environment variables' unless @host && @username && @password && @domain_name
        
        @enrollment        = args[:enrollment]
        @publisher         = args[:publisher] || PipelinePublisher
        @api_instance      = args[:message_api] || PipelinePublisher::MessagesApi.new
        @user              = args[:user]
        @serializer        = PipelineUserAPI
        @message_builder   = args[:message_builder] || publisher::Message
      end

      def call
        configure
        @payload = serialize_enrollment
        @message = build_pipeline_message
        post
        self
      end

      private

      attr_reader :payload, :enrollment, :username, :password,
        :user, :api_instance, :payload, :publisher, :host,
        :serializer, :domain_name, :message_builder

      def configure
        publisher.configure do |config|
          config.host     = host
          config.username = username
          config.password = password
        end
      end

      def post
        api_instance.messages_post(message)
      end
      handle_asynchronously :post

      def serialize_enrollment
        serializer.new.enrollment_json(
          enrollment,
          user,
          {}
        )
      end

      def build_pipeline_message
        message_builder.new(
          noun:         MESSAGE_NAME,
          meta:         {
                          source: SOURCE,
                          domain_name: domain_name
                        },
          identifiers:  { id: enrollment.id },
          data:         payload
        )
      end
    end
  end
end
