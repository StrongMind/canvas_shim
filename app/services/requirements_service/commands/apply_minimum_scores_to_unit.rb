module RequirementsService
  module Commands
    class ApplyMinimumScoresToUnit
      def initialize(context_module:, force: false)
        @context_module = context_module
        @completion_requirements = context_module.completion_requirements
        @force = force
        @course = context_module.course
      end

      def call
        strip_overrides if force
        context_module.send(:add_min_score_to_requirements)
        context_module.update_column(:completion_requirements, completion_requirements)
        context_module.touch
      end

      private

      attr_reader :completion_requirements, :context_module, :course, :force

      def strip_overrides
        SettingsService.update_settings(
          object: 'course',
          id: course.try(:id),
          setting: 'threshold_overrides',
          value: false
        )
      end
    end
  end
end


