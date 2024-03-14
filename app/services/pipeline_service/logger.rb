module PipelineService
  class Logger
    HEADERS = {}
    def initialize(message, args={})
      @message = message
      @args = args
      configure_dependencies
    end

    def call
      queue.enqueue(self)
    end

    # This makes it possible for the instance to be run later by Delayed::Job
    def perform
      post
    end

    private

    attr_reader :http_client, :message, :queue

    def configure_dependencies
      @queue       = @args[:queue] || Delayed::Job
      @http_client = @args[:http_client] || HTTParty
    end

    def post
      # empty body temporarily to get us through an outage, in case there are multiple places calling this.
    end
  end
end
