module PipelineService
    module Builders
      class CourseProgressJSONBuilder
        def self.call(noun)
          user = User.find noun.user_id
          course = Course.find noun.course_id
          course_progress = CourseProgress.new(course, user).to_json
          course_updated_at = ContextModuleProgression.find(noun.id).updated_at
          course_progress['updated_at'] = course_updated_at
          course_progress
        end
      end
    end
  end
  