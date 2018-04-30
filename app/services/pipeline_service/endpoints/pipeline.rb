module PipelineService
  module Endpoints
    class Pipeline
      def initialize(message:, args: {})
        @message     = message
        @args        = args
      end

      def call
        enqueue
      end

      private

      attr_reader :message, :args

      def enqueue
        Delayed::Job.enqueue PostMessageJob.new(message, args)
      end
    end
  end
end
