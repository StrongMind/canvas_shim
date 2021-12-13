module PipelineService
  module V2
    module API
      class Publish
        def initialize(model)
          @model = model
        end

        def call
          @noun = Noun.new(@model)
          @payload = Payload.new(
            object: @noun
          )
          payload = @payload.call
          PipelineService::V2::Commands::PublishToPipeline.new(payload).call
        end
        handle_asynchronously :call, :priority => 1000000
      end
    end
  end
end
