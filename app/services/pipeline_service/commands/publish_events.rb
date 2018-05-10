module PipelineService
  module Commands
    class PublishEvents
      def initialize(object, args={})
        @object        = object
        @subscriptions = args[:subscriptions]
        @changes       = object.changes
      end

      def call
        return unless subscriptions
        Events::Emitter.new(
          message:       message,
          changes:       changes,
          subscriptions: subscriptions
        ).call
      end

      private

      attr_accessor :message, :subscriptions, :changes

      def build_message
        @message = PipelineService::AMessageBuilder.new
      end

      def emit
        Events::Emitter.new(
          message:       message.merge(changes: changes),
          subscriptions: subscriptions
        ).call
      end
    end
  end
end
