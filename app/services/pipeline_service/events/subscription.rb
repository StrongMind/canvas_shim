module PipelineService
  module Events
    class Subscription
      attr_reader :listeners
      def initialize(listeners: [])
        @listeners = listeners
      end
    end
  end
end
