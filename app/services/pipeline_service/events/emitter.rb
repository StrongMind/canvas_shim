module PipelineService
  module Events
    class Emitter
      def initialize(args={})
        @object = args[:object]
        @args = args
        @responder  = @args[:responder] || Events::Responders::SIS
        @event = Events::GradedOutEvent
      end

      def call
        fetch_serializer
        build_message
        build_responder
        build_subscriptions
        emit
      end

      private

      attr_reader :subscriptions, :object, :responder, :message, :serializer, :event

      def build_subscriptions
        @subscriptions = [
          Events::Subscription.new(
            event: :graded_out,
            responder: responder
          )
        ]
      end

      def build_responder
        @responder = responder.new(
          object: object,
          message: message
        )
      end

      def fetch_serializer
        @serializer = Serializers::Fetcher.fetch(object: object)
      end

      def build_message
        @message = serializer.new(object: object).call
      end

      def emit
        subscriptions.each do |subscription|
          next if subscription.event != :graded_out
          event.new(
            responder: subscription.responder,
            object: object
          ).emit
        end
      end
    end
  end
end
