module GradesService
  module Commands
    class ZeroOutAssignmentGrades
      EXCLUDE_WORKFLOW_STATES = ['submitted', 'graded']
      def initialize(submission)
        @submission = submission
        @assignment = submission.assignment
        @student = submission.user
        @grader = grader
      end

      def call!
        return if should_not_grade?
        @assignment.grade_student(@student, score: 0, grader: grader)
      end

      private

      def still_submittable?
        @submission.due_at > 1.hour.ago
      end

      def scored?
        @submission.score.present? || @submission.grade.present?
      end

      def submitted?
        EXCLUDE_WORKFLOW_STATES.include? @submission.workflow_state
      end

      def unpublished?
        !@assignment.published?
      end

      def grader
        GradesService::Account.account_admin
      end

      def should_not_grade?
        submitted? || scored? || still_submittable? || unpublished?
      end
    end
  end
end
