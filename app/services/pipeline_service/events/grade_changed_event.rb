module PipelineService
  module Events
    class GradeChangedEvent
      def initialize args
        @args = args
        @subscription = args[:subscription]
        @object = args[:object]
        @changes = args[:changes]
      end

      def emit
        return unless should_trigger?
        @subscription.responder.call
      end

      private

      def should_trigger?
        return false unless @changes['score']
        @object.is_a?(::Submission)
      end
    end
  end
end
