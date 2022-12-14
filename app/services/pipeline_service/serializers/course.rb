module PipelineService
  module Serializers
    class Course
      def initialize object:
        @course = object
      end

      def call
        @payload = Builders::CourseJSONBuilder.call(@course) || {}
        @payload.merge!(passing_thresholds)
        if SettingsService.get_settings(object: :school, id: 1)['powerschool_integration']
          @payload.merge!(powerschool_ids)
        end
        @payload
      end

      def passing_thresholds
        { 'passing_thresholds' => get_assignment_group_passing_thresholds }
      end

      def powerschool_ids
          {
            'powerschool_school_id': SettingsService.get_settings(object: :course, id: @course.id)['powerschool_course_id_school_id'] || IdentifierMapperService::Client.get_powerschool_school_id,
            'powerschool_course_id': SettingsService.get_settings(object: :course, id: @course.id)['powerschool_course_id']
          }
      end

      def format_threshold(method)
        threshold = RequirementsService.send(method, @course)
        return nil if threshold.nil?
        threshold.to_f
      end

      def get_assignment_group_passing_thresholds
        RequirementsService.get_assignment_group_passing_thresholds(context: @course)
      end
    end
  end
end
