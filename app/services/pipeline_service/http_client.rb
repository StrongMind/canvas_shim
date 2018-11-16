module PipelineService
  class HTTPClient
    include Singleton

    def self.post(args)
      instance.post(args)
    end

    def self.get(endpoint, args={})
      instance.get(endpoint, args)
    end

    def post(args)
      message = PipelinePublisher::Message.new(args)
      PipelinePublisher::MessagesApi.new.messages_post(message)
    end

    def get(endpoint, args)
      HTTParty.get(endpoint, args)
    end
  end
end
