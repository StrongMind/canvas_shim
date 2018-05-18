module PipelineService
  class HTTPClient
    include Singleton

    def self.post(args)
      instance.post(args)
    end

    def post(args)
      PipelinePublisher::MessagesApi.new.messages_post(*args)
    end
  end
end
