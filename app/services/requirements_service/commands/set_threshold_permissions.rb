module RequirementsService
  module Commands
    class SetThresholdPermissions
      def initialize(course_thresholds:, post_enrollment:, module_editing:)
        @course_thresholds = course_thresholds
        @post_enrollment = post_enrollment
        @module_editing = module_editing
      end

      def call
        set_course_threshold_enablement
        set_post_enrollment_thresholds
        set_module_editing
      end

      private
      attr_reader :course_thresholds, :post_enrollment, :module_editing

      def set_course_threshold_enablement
        SettingsService.update_settings(
          object: 'school',
          id: 1,
          setting: 'course_threshold_enabled',
          value: course_thresholds
        )
      end

      def set_post_enrollment_thresholds
        SettingsService.update_settings(
            object: 'school',
            id: 1,
            setting: 'enable_post_enrollment_threshold_updates',
            value: (course_thresholds && post_enrollment)
          )
      end

      def set_module_editing
        SettingsService.update_settings(
          object: 'school',
          id: 1,
          setting: 'disable_module_editing',
          value: module_editing
        )
      end
    end
  end
end