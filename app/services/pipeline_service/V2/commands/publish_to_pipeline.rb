module PipelineService
  module V2
    module Commands
      class PublishToPipeline
        def initialize(payload)
          @payload = payload
        end

        def call
          Client.publish(@payload)
        end
      end
    end
  end
end
