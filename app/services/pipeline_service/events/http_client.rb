module PipelineService
  module Events
    class HTTPClient
      include Singleton
      def self.post(endpoint, args={})
        instance.post(endpoint, args)
      end

      def post(endpoint, args)
        HTTParty.post(endpoint, args)
      end
    end
  end
end
