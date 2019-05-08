module PipelineService
  module V2
    module API
      class Publish
        def initialize(model)
          @model = model
          @noun = Models::V2::Noun.new(model)
          @message_builder = MessageBuilder.new(
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