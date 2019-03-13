module PipelineService
    module Models
        class Identifier
            def initialize(field, options={})
                @field = field
                @field_alias = options[:alias]
            end

            def to_a(instance)
                return field.call(instance) if field.is_a?(Proc)
                return [field_alias, instance.send(field)] if field_alias
                [field, instance.send(field)] 
            end

            def to_h
                return [[field, field_alias]].to_h
            end

            private

            attr_accessor :field_alias, :field, :instance
        end
    end
end