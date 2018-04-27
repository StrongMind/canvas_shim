module PipelineService
  module Events
    class Subscription
      attr_reader :listener, :event
      def initialize(event:, listener: nil)
        @listener = listener
        @event = event
      end
    end
  end
end
