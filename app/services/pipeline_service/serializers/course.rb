module PipelineService
  module Serializers
    class Course
      def initialize object:
        @course = object
      end

      def call
        @payload = Builders::CourseJSONBuilder.call(@course) || {}
        @payload.merge!(passing_thresholds)
        @payload.merge!(powerschool_ids)
      end

      def passing_thresholds
        { 'passing_thresholds' => {
            'assignment' => format_threshold(:get_course_assignment_passing_threshold?),
            'exam' => format_threshold(:get_course_exam_passing_threshold?)
          }
        }
      end

      def powerschool_ids
          {
            'powerschool_school_id': IdentityMapperService.get_powerschool_school_id,
            'powerschool_course_id': IdentityMapperService.get_powerschool_course_id(@course.id)
          }
      end

      def format_threshold(method)
        threshold = RequirementsService.send(method, @course)
        return nil if threshold.nil?
        threshold.to_f
      end
    end
  end
end
