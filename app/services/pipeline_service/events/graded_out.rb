module PipelineService
  module Events
    class GradedOut
      def initialize(args)
        @responder = args[:responder]
        @message   = args[:message]
      end

      def emit
        return unless should_trigger?
        responder.call
      end

      private

      attr_accessor :responder, :message

      def should_trigger?
        return unless message[:noun] == 'student_enrollment'
        return unless message[:data][:enrollment_state] == 'completed'
        true
      end
    end
  end
end
