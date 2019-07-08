module PipelineService
    module Models
        class Identifier
            attr_accessor :field_alias, :field, :instance
            
            # the field parameter can be a symbol or a proc.  A proc 
            # should return an array with the field name and call a 
            # value from the instance passed into #to_a
            #
            # Proc.new do |submission| 
            #   [:course_id, submission.assignment.course.id]
            # end
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
        end
    end
end