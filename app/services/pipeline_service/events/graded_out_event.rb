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
        subscription.responder.call
      end

      private

      attr_accessor :subscription
    end
  end
end
