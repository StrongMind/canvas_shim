module PipelineService
  module Events
    class Emitter
      def initialize(args={})
        @subscriptions = args[:subscriptions]
        @message = args[:message]
      end

      def call
        puts 0, 'calling subscriptions'
        subscriptions.each do |subscription|
          Events::GradedOutEvent.new(
            responder: subscription.responder,
            message:   message
          ).emit if subscription.event == :graded_out
        end
      end

      private

      attr_reader :subscriptions, :message
    end
  end
end
