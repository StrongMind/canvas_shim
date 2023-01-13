module RequirementsService
  module Commands
    class SetSchoolThresholdsOnCourse

      def initialize(course:)
        @course = course
      end

      def call
        account_level_thresholds = get_default_course_thresholds(passing_threshold_group_names)
        set_default_course_thresholds(account_level_thresholds)
      end

      def passing_threshold_group_names
        AssignmentGroup.passing_threshold_group_names
      end

      private
      attr_reader :course

      def set_default_course_thresholds(thresholds)
        thresholds.each do |assignment_group_name, value|
          threshold_setting_name = "#{assignment_group_name}_passing_threshold"
          SettingsService.update_settings(
            object: 'course',
            id: course.id,
            setting: threshold_setting_name,
            value: value
          )
        end
      end

      def get_default_course_thresholds(assignment_group_names)
        thresholds = {}
        assignment_group_names.each do |group_name|
          thresholds[group_name] = RequirementsService.get_passing_threshold(type: 'school', assignment_group_name: group_name)
        end
        thresholds
      end
    end
  end
end
