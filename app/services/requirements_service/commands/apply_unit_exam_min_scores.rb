module RequirementsService
  module Commands
    class ApplyUnitExamMinScores < ApplyAssignmentMinScores
      def initialize(context_module:, force: false)
        super
        @threshold_exists = !!settings['passing_exam_threshold']
        @score_threshold = settings['passing_exam_threshold'].to_f
      end

      def reset_requirements
        RequirementsService.reset_requirements(
            context_module: context_module, 
            exam: true
          )
      end

      def threshold_changes_needed?
        return false unless score_threshold.positive?
        completion_requirements.any? do |req|
          unit_exam?(req) && (is_submittable?(req) || min_score_different_than_threshold?(req))
        end
      end

      def skippable_requirement?(requirement)
        has_threshold_override?(requirement) ||
        not_unit_exam?(requirement)
      end
    end
  end
end