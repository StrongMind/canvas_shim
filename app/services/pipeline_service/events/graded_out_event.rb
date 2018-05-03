module PipelineService
  module Events
    class GradedOutEvent
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
        return unless recently_completed?
        true
      end

      def recently_completed?
        puts 'a0', 'checking meta'
        puts message
        return unless message[:meta]
        puts 'a1', 'meta exists'
        return unless message[:meta][:changes]
        puts 'a2', 'meta changes exists'
        message[:meta][:changes]['workflow_state'].try(:[], 1) == 'completed'
      end
    end
  end
end
