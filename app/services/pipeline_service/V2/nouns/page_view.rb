module PipelineService
  module V2
    module Nouns
      class PageView
        def initialize object:
          @page_view = object.ar_model
        end

        def call
          # Return the default, non-overrriden from #as_json
          @page_view
            .class
            .superclass
            .instance_method(:as_json)
            .bind(@page_view)
            .call(include_root: false)
        end
      end
    end
  end
end
