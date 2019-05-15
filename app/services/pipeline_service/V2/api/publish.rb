module PipelineService
  module V2
    module API
      class Publish
        def initialize(model)
          @model = model
          @noun = Noun.new(model)
          @payload = Payload.new(
            object: @noun
          )
        end

        def call
          payload = @payload.call
          Commands::PublishToPipeline.new(payload).call
        end
      end
    end
  end
end