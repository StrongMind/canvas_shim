module PipelineService
  module V2
    module Nouns
      class Course < PipelineService::V2::Nouns::Base
        def initialize object:
          @ar_object = object.ar_model
        end

        def call
          # Return the default, non-overrriden from #as_json
          super.merge(passing_threshold)
        end

        def passing_threshold
          { 'passing_thresholds' => {
              'assignment' => RequirementsService.get_course_assignment_passing_threshold?(@ar_object),
              'exam' => RequirementsService.get_course_exam_passing_threshold?(@ar_object)
          }
        }
        end
      end
    end
  end
end
