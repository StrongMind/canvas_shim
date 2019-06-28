module RequirementsService
  module Commands
    class SetSchoolThresholdsOnCourse
      def initialize(course:)
        @course = course
      end

      def call
        set_default_course_threshold if account_threshold_set?
        set_default_course_exam_threshold if account_exam_threshold_set?
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

      def set_default_course_exam_threshold
        SettingsService.update_settings(
          object: 'course',
          id: course.id,
          setting: 'passing_exam_threshold',
          value: account_exam_threshold
        )
      end
    
      def account_threshold
        RequirementsService.get_passing_threshold(type: :school)
      end

      def account_threshold_set?
        account_threshold.positive?
      end

      def account_exam_threshold
        RequirementsService.get_passing_threshold(type: :school, exam: true)
      end

      def account_exam_threshold_set?
        account_exam_threshold.positive?
      end
    end
  end
end