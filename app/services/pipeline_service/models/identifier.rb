module PipelineService
    module Models
        class Identifier
            def initialize(field, options={})
                @field = field
                @field_alias = options[:alias]
            end

            def to_a(instance)
                return [field, instance.send(field)] unless field_alias
                [field_alias, instance.send(field)]
            end

            def to_h
                return [[field, field_alias]].to_h
            end

            private

            attr_accessor :field_alias, :field, :instance
        end
    end
end