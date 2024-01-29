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

        if SettingsService.get_settings(object: :school, id: 1)['zero_out_extended_log'] == 'on'
          extended_log_operation
        else
          log_operation
        end

        @assignment.grade_student(@student, score: 0, grader: @grader)

        if @submission.context.is_a?(Course)
          @submission.context.student_enrollments.where(user: @submission.user).each do |student_enrollment|
            Enrollment.recompute_final_score(student_enrollment.user_id, student_enrollment.course_id)
          end
        end
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

      def extended_log_operation
        return unless @options[:log_file]

        begin
          csv = CSV.open('/tmp/' + @options[:log_file], 'a+')
          csv << [@submission.id,
                  @previous_score,
                  @submission.cached_due_date,
                  @assignment.due_at,
                  @assignment.overridden ? "true" : "false",
                  @assignment.external_tool_tag.try(:url)]
          csv.close
        rescue => e
          raise e, 'error opening log file'
        end
      end

      def late?
        return @submission.cached_due_date.present? && 1.hour.ago > @submission.cached_due_date
      end

      def unscored?
        @submission.score.nil? && @submission.grade.nil?
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

      def not_excused?
        !@submission.excused?
      end

      def should_grade?
        not_excused? && unsubmitted? && unscored? && late? && published? && enrolled?
      end
    end
  end
end
