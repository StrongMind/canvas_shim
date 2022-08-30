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

          # commenting out due to overactive alerting. Not deleting in case of repurposing code next sprint
          # if powerschool_ids.values.any?(&:nil?)
            # Sentry.capture_message("powerschool ids has at least one null value in Noun for course #{@course}")
          # end
        end
        @payload
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
            'powerschool_school_id': SettingsService.get_settings(object: :course, id: @course.id)['powerschool_course_id_school_id'] || IdentifierMapperService::Client.get_powerschool_school_id,
            'powerschool_course_id': SettingsService.get_settings(object: :course, id: @course.id)['powerschool_course_id']
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
