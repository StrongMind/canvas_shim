module GradesService
  module Commands
    class ZeroOutAssignmentGrades
      EXCLUDE_WORKFLOW_STATES = ['submitted', 'graded']
      def initialize(submission)
        @previous_score = submission.score
        @submission = submission
        @assignment = @submission.assignment
        @student = @submission.user
        @course = @assignment.context
        @grader = GradesService::Account.account_admin
      end

      def call!(options={})
        return unless should_grade?

        if options[:dry_run]
          log_execution_plan
          return
        end

        log_operation
        @assignment.mute!
        @assignment.grade_student(@student, score: 0, grader: @grader)
        @assignment.unmute!
      end

      private

      def log_execution_plan
        file = File.open('dry_run.log', 'a')
        file.write("Changing submission #{@submission.id} from #{@previous_score || 'nil'} to 0\n")
        file.close
      end

      def log_operation
        SettingsService.update_settings(
          id: @submission.id,
          setting: 'zero_grader_previous_score',
          value: @previous_score,
          object: 'submission',
        )
      end

      def late?
        return @assignment.due_at.present? && 1.hour.ago > @assignment.due_at
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

      def enrolled?
        @course.includes_user?(@student, @course.admin_visible_student_enrollments)
      end

      def should_grade?
        !submitted? && !scored? && late? && published? && enrolled?
      end
    end
  end
end
