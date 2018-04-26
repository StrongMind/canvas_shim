module PipelineService
  module Commands
    class PublishEvents
      def initialize(message, args={})
        @message       = message
        @subscriptions = args[:subscriptions]
      end

      def call
        return unless subscriptions
        Events::Emitter.new(
          message:       message,
          subscriptions: subscriptions
        ).call
      end

      private

      attr_accessor :message, :subscriptions
    end
  end
end
