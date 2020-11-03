module PipelineService
  module V2
    module Commands
      class PublishToPipeline
        def initialize(payload)
          @payload = payload
        end

        def call
          @payload['published_at'] = Time.now.to_f
          Client.publish(@payload)
        end
      end
    end
  end
end
