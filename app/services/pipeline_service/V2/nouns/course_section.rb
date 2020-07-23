module PipelineService
  module V2
    module Nouns
      class CourseSection < PipelineService::V2::Nouns::Base
        def initialize object:
          @ar_object = object.ar_model
        end
      end
    end
  end
end
