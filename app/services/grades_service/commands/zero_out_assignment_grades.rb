module GradesService
  module Commands
    class ZeroOutAssignmentGrades
      def initialize(submission)
        @previous_score = submission.score
        @submission = submission
        @assignment = @submission.assignment
        @student = @submission.user
        @course = @assignment.context
        @grader = GradesService::Account.account_admin
      end

      def call!(options={})
        return unless options[:log_file]
        return unless SettingsService.get_settings(object: :school, id: 1)['zero_out_past_due'] == 'on'
        @options = options
        return unless should_grade?

        if options[:dry_run]
          log_execution_plan
          return
        end

        log_operation
        @assignment.grade_student(@student, score: 0, grader: @grader)
      end

      private

      def log_execution_plan
        file = File.open('dry_run.log', 'a+')
        file.write("Changing submission #{@submission.id} from #{@previous_score || 'nil'} to 0\n")
        file.close
      end

      def log_operation
        return unless @options[:log_file]

        begin
          csv = CSV.open('/tmp/' + @options[:log_file], 'a+')
          csv << [@submission.id, @previous_score]
          csv.close
        rescue => e
          raise e, 'error opening log file'
        end
      end

      def late?
        return @assignment.due_at.present? && 1.hour.ago > @assignment.due_at
      end

      def unscored?
        @submission.score.nil? || @submission.grade.nil?
      end

      def unsubmitted?
        @submission.workflow_state == 'unsubmitted'
      end

      def published?
        @assignment.published?
      end

      def enrolled?
        @course.includes_user?(@student, @course.admin_visible_student_enrollments)
      end

      def should_grade?
        unsubmitted? && unscored? && late? && published? && enrolled?
      end
    end
  end
end
