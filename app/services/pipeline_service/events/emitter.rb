module PipelineService
  module Events
    class Emitter
      def initialize(args={})
        @subscriptions = args[:subscriptions]
        @message = args[:message]
        @changes = args[:changes]
      end

      def call
        subscriptions.each do |subscription|
          Events::GradedOutEvent.new(
            responder: subscription.responder,
            message:   message,
            changes:   changes
          ).emit if subscription.event == :graded_out
        end
      end

      private

      attr_reader :subscriptions, :message, :changes
    end
  end
end
