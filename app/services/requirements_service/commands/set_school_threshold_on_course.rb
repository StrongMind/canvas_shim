module RequirementsService
  module Commands
    class SetSchoolThresholdOnCourse
      def initialize(course:)
        @course = course
      end

      def call
        set_default_course_threshold if account_threshold_set?
      end

      private
      attr_reader :course

      def set_default_course_threshold
        SettingsService.update_settings(
          object: 'course',
          id: course.id,
          setting: 'passing_threshold',
          value: account_threshold
        )
      end
    
      def account_threshold
        RequirementsService.get_passing_threshold(type: :school)
      end
    
      def account_threshold_set?
        account_threshold.positive?
      end
    end
  end
end