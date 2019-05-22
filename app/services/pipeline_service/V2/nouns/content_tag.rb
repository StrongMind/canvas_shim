module PipelineService
  module V2
    module Nouns
      class ContentTag
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
            .merge resource_link_id

        end

        def resource_link_id
          { 'resource_link_id' => Lti::Asset.opaque_identifier_for(@ar_object) }
        end

      end
    end
  end
end
