module RequirementsService
  module Commands
    class ApplyProjectMinScores < ApplyAssignmentMinScores
      def initialize(context_module:, force: false)
        super
        @threshold_exists = !!settings['passing_project_threshold']
        @score_threshold = settings['passing_project_threshold'].to_f
      end

      def reset_requirements
        RequirementsService.reset_requirements(
          context_module: context_module,
          threshold_type: 'project'
        )
      end

      def threshold_changes_needed?
        if score_threshold.positive?
          true
        else
          false
        end
      end

      def skippable_requirement?(requirement)
        has_threshold_override?(requirement)
      end
    end
  end
end
