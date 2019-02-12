module PipelineService
    module Models
        class Noun
            attr_reader :id, :name
            
            def initialize(noun)
                @id = noun.id
                @name = noun.class.to_s
            end

            def name
                return "Enrollment" if @name.include?('Enrollment')
                @name
            end
        end
    end
end