module PipelineService
  module Events
    class Emitter
      def initialize args={}
        @object = args[:object]
        @args = args
      end

      def call
        fetch_serializer
        return unless serializer
        build_message
        build_subscriptions
        emit
      end

      private

      attr_reader :subscriptions, :object, :responder, :message, :serializer

      def events
        {
          graded_out: Events::GradedOutEvent,
          grade_changed: Events::GradeChangedEvent
        }
      end

      def build_subscriptions
        @subscriptions = []

        @subscriptions << Events::Subscription.new(
          event: :graded_out,
          responder: Events::Responders::SIS.new(
            object: object,
            message: message
          )
        )

        @subscriptions << Events::Subscription.new(
          event: :grade_changed,
          responder: Events::Responders::SISUnitGrade.new(
            object: object,
            message: message
          )
        )
      end

      def fetch_serializer
        @serializer =
        if object.noun_class == PipelineService::Nouns::UnitGrades
          Serializers::UnitGrades
        elsif object.noun_class == StudentEnrollment
          Serializers::CanvasAPIEnrollment
        end
      end

      def build_message
        return {} if object.destroyed?
        instance = serializer.new(object: object)
        @message = instance.call
      end

      def emit
        subscriptions.each do |subscription|
          next unless events[subscription.event]
          events[subscription.event].new(
            @args.merge(subscription: subscription)
          ).emit
        end
      end
    end
  end
end
