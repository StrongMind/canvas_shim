module PipelineService
  module API
    module V2
      class Publish
        def initialize(model)
          @model = model
          @noun = Models::V2::Noun.new(model)
          @message_builder = Endpoints::Pipeline::MessageBuilder.new(
            object: @noun
          )
        end

        def call
          @message_builder.call
        end
      end
    end
  end
end