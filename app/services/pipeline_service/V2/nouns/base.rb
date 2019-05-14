module PipelineService
  module V2
    module Nouns
      class Base
        def initialize object:
          @ar_object = object.ar_model
        end

        def call
          # Return the default, non-overrriden from #as_json
          @ar_object
            .class
            .superclass
            .instance_method(:as_json)
            .bind(@ar_object)
            .call(include_root: false)
        end
      end
    end
  end
end
