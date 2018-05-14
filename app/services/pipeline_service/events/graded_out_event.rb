module PipelineService
  module Events
    class GradedOutEvent
      def initialize(args)
        @args = args
        @responder = args[:responder]
        @object    = args[:object]
      end

      def emit
        return unless should_trigger?
        responder.call
      end

      private

      attr_accessor :responder, :object

      def should_trigger?
        return unless object.is_a?(::Enrollment)
        recently_completed?
      end

      def recently_completed?
        object.changes['workflow_state'].try(:[], 1) == 'completed'
      end
    end
  end
end
