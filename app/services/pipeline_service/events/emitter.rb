module PipelineService
  module Events
    class Emitter
      def initialize(args={})
        @object = args[:object]
        @args = args
        @responder  = @args[:responder] || Events::Responders::SIS
      end

      def call
        build_message
        build_responder
        build_subscriptions
        emit
      end

      private

      attr_reader :subscriptions, :object, :responder, :message, :event

      def event
        {
          graded_out: Events::GradedOutEvent,
          grade_changed: Events::GradeChangedEvent
        }
      end

      def build_subscriptions
        @subscriptions = [:graded_out, :grade_changed].map do |event_name|
          Events::Subscription.new(event: event_name, responder: responder)
        end
      end

      def build_responder
        @responder = responder.new(
          object: object,
          message: message
        )
      end

      def serializer
        case(object)
        when Submission
          Serializers::Submission
        when Enrollment
          Serializers::CanvasAPIEnrollment
        end
      end

      def build_message
        @message = serializer.new(object: object).call
      end

      def emit
        subscriptions.each do |subscription|
          event[subscription.event].new(
            @args.merge(subscription: subscription)
          ).emit
        end
      end
    end
  end
end
