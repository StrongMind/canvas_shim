module PipelineService
  module Events
    class GradedOutEvent
      def initialize(args)
        @args = args
        @subscription = args[:subscription]
        @object    = args[:object]
        @changes   = args[:changes]
      end

      def emit
        return unless should_trigger?
        subscription.responder.call
      end

      private

      attr_accessor :subscription, :object, :changes

      def should_trigger?

        return unless object.noun_class == ::Enrollment
        recently_completed?
      end

      def recently_completed?
        return false unless changes['workflow_state']
        changes['workflow_state'][1] == 'completed'
      end
    end
  end
end
