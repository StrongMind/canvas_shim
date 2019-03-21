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
        @subscription.responder.call
      end
    end
  end
end
