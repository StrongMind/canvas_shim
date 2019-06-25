module RequirementsService
  module Commands
    class EnableThresholdPermissions
      def initialize(course_thresholds:, post_enrollment:, module_editing:)
        @course_thresholds = course_thresholds
        @post_enrollment = post_enrollment
        @module_editing = module_editing
      end

      def call
        update_settings('course_threshold_enabled', course_thresholds)
        update_settings('enable_post_enrollment_threshold_updates', module_editing)
        update_settings('disable_module_editing', (course_thresholds && post_enrollment))
      end

      private
      attr_reader :course_thresholds, :post_enrollment, :module_editing

      def update_settings(setting, value)
        SettingsService.update_settings(
          object: 'school',
          id: 1,
          setting: setting,
          value: value
        )
      end
    end
  end
end