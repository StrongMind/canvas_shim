module PipelineService
    module Helpers
        class DeletedNoun
            attr_reader :id, :name
            
            def initialize(noun)
                @id = noun.id
                @name = noun.class.to_s
            end
        end
    end
end