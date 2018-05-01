module PipelineService
  module Events
    class Subscription
      attr_reader :responder, :event
      def initialize(event:, responder: nil)
        @responder = responder
        @event = event
      end
    end
  end
end
