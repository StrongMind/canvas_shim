module RequirementsService
  module Commands
    class SetSchoolThresholdsOnCourse
      ASSIGNMENT_GROUP_NAMES = AssignmentGroup::GROUP_NAMES.map{|n| n.downcase.gsub(/\s/, "_")}

      def initialize(course:)
        @course = course
      end

      def call
        account_level_thresholds = get_default_course_thresholds(ASSIGNMENT_GROUP_NAMES)
        set_default_course_thresholds(account_level_thresholds)
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