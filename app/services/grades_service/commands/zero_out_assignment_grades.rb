module GradesService
  module Commands
    class ZeroOutAssignmentGrades
      EXCLUDE_WORKFLOW_STATES = ['submitted', 'graded']
      def initialize(submission)
        @previous_score = submission.score || 'nil'
        @submission = submission
        @assignment = submission.assignment
        @student = submission.user
        @grader = GradesService::Account.account_admin
      end

      def call!(options={})
        return unless should_grade?

        if options[:dry_run]
          log_execution_plan
          return
        end

        @assignment.grade_student(@student, score: 0, grader: @grader)
      end

      private

      def log_execution_plan
        file = File.open('dry_run.log', 'a')
        file.write("Changing submission #{@submission.id} from #{@previous_score} to 0\n")
        file.close
      end

      def still_submittable?
        @submission.due_at > 1.hour.ago
      end

      def scored?
        @submission.score.present? || @submission.grade.present?
      end

      def submitted?
        EXCLUDE_WORKFLOW_STATES.include? @submission.workflow_state
      end

      def published?
        @assignment.published?
      end

      def should_grade?
        !submitted? && !scored? && !still_submittable? && published?
      end
    end
  end
end
