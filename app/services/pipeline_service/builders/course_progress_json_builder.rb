module PipelineService
    module Builders
      class CourseProgressJSONBuilder
        def self.call(noun)
          # Dont include root.  See active record initializer
          # Queries::FindByID.query(self, noun)
          user = User.find noun.user_id
          course = Course.find noun.course_id
          CourseProgress.new(course, user).to_json
        end
      end
    end
  end
  