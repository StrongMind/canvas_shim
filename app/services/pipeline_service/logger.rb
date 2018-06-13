module PipelineService
  class Logger
    include Singleton

    class << self
      extend Forwardable
      def_delegators :instance, :call, :perform
    end

    HEADERS = {}

    def call(message, args={})
      if PipelineService.perform_synchronously?
        perform
      else
        queue.enqueue(self)
      end
    end

    # This makes it possible for the instance to be run later by Delayed::Job
    def perform
      post
    end

    private

    attr_reader :message

    def post
      http_client.post(
        'https://3wupzgqsoh.execute-api.us-west-2.amazonaws.com/prod',
        body: message.to_json
      )
    end

    def http_client
      HTTParty
    end

    def queue
      Delayed::Job
    end
  end
end
