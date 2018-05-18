module PipelineService
  module Events
    class HTTPClient
      include Singleton
      def self.post(*args)
        instance.post(args)
      end

      def post(*args)
        binding.pry
        HTTParty.post(args)
      end
    end
  end
end
