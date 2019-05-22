module PipelineService
  module V2
    module Nouns
      class ContentTag < PipelineService::V2::Nouns::Base
        def initialize object:
          @ar_object = object.ar_model
        end

        def call
          super.merge(resource_link_id)
        end

        def resource_link_id
          { 'resource_link_id' => Lti::Asset.opaque_identifier_for(@ar_object) }
        end
      end
    end
  end
end
