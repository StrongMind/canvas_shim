module PipelineService
    module Serializers
      class CourseProgress
        def initialize object:
          @course = object
        end
  
        def call
          @payload = Builders::CourseProgressJSONBuilder.call(@course) || {}
        end
  
      end
    end
  end
  