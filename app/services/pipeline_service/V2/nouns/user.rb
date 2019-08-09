module PipelineService
  module V2
    module Nouns
      class User < PipelineService::V2::Nouns::Base
        def initialize object:
          @ar_object = object.ar_model
        end

        def call
          # Return the default, non-overrriden from #as_json
          super.merge sis_user_id
        end

        def sis_user_id
          { 'sis_user_id' => @ar_object.pseudonyms.first.try(:sis_user_id) }
        end

      end
    end
  end
end
