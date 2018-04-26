module DomainEvents
  module Commands
    class ParsePipelineMessage
      def initialize(message, args={})
        @message       = message
        @subscriptions = args[:subscriptions]
      end

      def call
        return unless subscriptions
        DomainEvents::EventEmitter.new(
          message:       message,
          subscriptions: subscriptions
        ).call
      end

      private

      attr_accessor :message, :subscriptions
    end
  end
end
