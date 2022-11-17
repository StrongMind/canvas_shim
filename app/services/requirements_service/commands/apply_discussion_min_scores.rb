module RequirementsService
  module Commands
    class ApplyDiscussionMinScores < ApplyAssignmentMinScores
      def initialize(context_module:, force: false)
        super
        @threshold_exists = !!settings['passing_discussion_threshold']
        @score_threshold = settings['passing_discussion_threshold'].to_f
      end

      def reset_requirements
        RequirementsService.reset_requirements(
          context_module: context_module,
          threshold_type: 'discussion'
        )
      end

      def threshold_changes_needed?
        if score_threshold.positive? && context_module.content_type == 'DiscussionTopic'
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
