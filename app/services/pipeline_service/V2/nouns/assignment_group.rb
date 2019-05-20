module PipelineService
  module V2
    module Nouns
      class AssignmentGroup
        def initialize object:
          @ar_object = object.ar_model
        end

        def call
          # Return the default, non-overrriden from #as_json
          json = @ar_object
            .class
            .superclass
            .instance_method(:as_json)
            .bind(@ar_object)
            .call(include_root: false)
          json.merge transform_context_id
        end

        def transform_context_id
          if @ar_object[:context_id] && @ar_object[:context_type]
            { "#{@ar_object[:context_type].downcase}_id".to_sym => @ar_object[:context_id]}
          else
            {}
          end
        end
      end
    end
  end
end
