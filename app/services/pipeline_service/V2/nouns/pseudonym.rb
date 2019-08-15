module PipelineService
  module V2
    module Nouns
      class Pseudonym < PipelineService::V2::Nouns::Pseudonym
        def initialize object:
          @ar_object = object.ar_model
        end
      end
    end
  end
end
