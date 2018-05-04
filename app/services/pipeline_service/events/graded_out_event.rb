module PipelineService
  module Events
    class GradedOutEvent
      def initialize(args)
        @responder = args[:responder]
        @message   = args[:message]
        @changes   = args[:changes]
      end

      def emit
        return unless should_trigger?
        responder.call
      end

      private

      attr_accessor :responder, :message, :changes

      def should_trigger?
        return unless message[:noun] == 'student_enrollment'
        return unless recently_completed?
        true
      end

      def recently_completed?
        changes['workflow_state'].try(:[], 1) == 'completed'
      end
    end
  end
end
