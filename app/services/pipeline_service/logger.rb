module PipelineService
  class Logger
    HEADERS = ''
    def initialize(message, args={})
      @message = message
      @http_client = args[:http_client] || HTTParty
    end

    def call
      post
    end

    private

    attr_reader :http_client, :message

    def post
      http_client.post(
        'http://lrs.strongmind.com/pipeline-watcher-staging',
        body:    message,
        headers: HEADERS
      )
    end
  end
end
