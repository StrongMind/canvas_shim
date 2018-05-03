module PipelineService
  module Commands
    class PublishEvents
      def initialize(message, args={})
        @message       = message
        @subscriptions = args[:subscriptions]
        @changes       = args[:changes]
      end

      def call
        return unless subscriptions
        Events::Emitter.new(
          message:       message.merge(changes: changes),
          subscriptions: subscriptions
        ).call
      end

      private

      attr_accessor :message, :subscriptions, :changes
    end
  end
end
