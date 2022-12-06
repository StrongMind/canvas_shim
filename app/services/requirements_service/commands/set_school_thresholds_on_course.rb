module RequirementsService
  module Commands
    class SetSchoolThresholdsOnCourse
      ASSIGNMENT_GROUP_NAMES = AssignmentGroup::GROUP_NAMES.map{|n| n.downcase.gsub(/\s/, "_")}

      def initialize(course:)
        @course = course
      end

      def call
        # set_default_course_threshold if account_threshold_set?
        # set_default_course_exam_threshold if account_exam_threshold_set?
        # set_default_course_discussion_threshold if account_discussion_threshold_set?
        # set_default_course_project_threshold if account_project_threshold_set?
        account_level_thresholds = get_default_course_thresholds(ASSIGNMENT_GROUP_NAMES)
        set_default_course_thresholds(account_level_thresholds)
      end

      private
      attr_reader :course

      def set_default_course_thresholds(thresholds)
        thresholds.each do |threshold_name, value|
          threshold_setting_name = "#{threshold_name}_passing_threshold"
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
          thresholds[group_name] = RequirementsService.get_passing_threshold(type: 'school', threshold_type: group_name)
        end
        thresholds
      end

      # def set_default_course_threshold
      #   SettingsService.update_settings(
      #     object: 'course',
      #     id: course.id,
      #     setting: 'passing_threshold',
      #     value: account_threshold
      #   )
      # end

      # def set_default_course_exam_threshold
      #   SettingsService.update_settings(
      #     object: 'course',
      #     id: course.id,
      #     setting: 'passing_exam_threshold',
      #     value: account_exam_threshold
      #   )
      # end

      # def set_default_course_discussion_threshold
      #   SettingsService.update_settings(
      #     object: 'course',
      #     id: course.id,
      #     setting: 'passing_discussion_threshold',
      #     value: account_discussion_threshold
      #   )
      #   end

      # def set_default_course_project_threshold
      #   SettingsService.update_settings(
      #     object: 'course',
      #     id: course.id,
      #     setting: 'passing_project_threshold',
      #     value: account_project_threshold
      #   )
      # end

      # def account_threshold
      #   RequirementsService.get_passing_threshold(type: :school)
      # end

      # def account_threshold_set?
      #   account_threshold.positive?
      # end

      # def account_exam_threshold
      #   RequirementsService.get_passing_threshold(type: :school, threshold_type: "exam")
      # end

      # def account_discussion_threshold
      #   RequirementsService.get_passing_threshold(type: :school, threshold_type: "discussion")
      # end

      # def account_project_threshold
      #   RequirementsService.get_passing_threshold(type: :school, threshold_type: "project")
      # end

      # def account_exam_threshold_set?
      #   account_exam_threshold.positive?
      # end

      # def account_discussion_threshold_set?
      #   account_discussion_threshold.positive?
      # end

      # def account_project_threshold_set?
      #   account_project_threshold.positive?
      # end
    end
  end
end