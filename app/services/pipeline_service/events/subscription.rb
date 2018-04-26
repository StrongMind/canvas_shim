module PipelineService
  module Events
    class Subscription
      attr_reader :listeners, :event
      def initialize(event:, listeners: [])
        @listeners = listeners
        @event = event
      end
    end
  end
end
