module GradesService
  module Commands
    class ZeroOutAssignmentGrades
      def initialize(id)
        @assignment = ::Assignment.find(id)
      end

      def call!
        return unless assignment.published?
        return if still_submittable?
        grade_students
      end

      private

      attr_reader :assignment

      def should_grade?(student)
        submission = submissions.find_by(user: student)
        if submission
          return submission.score.nil?
        else
          return true
        end
      end

      def submissions
        assignment.submissions
      end

      def grade_students
        students_without_submissions.each do |student|
          sg = should_grade?(student)
          if sg
            assignment.grade_student(student, score: 0, grader: grader)
          end
          record_auto_grader(student, sg)
        end
      end

      def record_auto_grader(student, success)
          SettingsService.update_settings(
            id: "#{student.id}:#{assignment.id}",
            setting: 'auto_zeroed_assigment',
            value: success,
            object: 'submission'
          )
      end

      def grader
        GradesService::Account.account_admin
      end

      def still_submittable?
        return true if assignment.due_date.nil?
        assignment.due_date > 1.hour.ago
      end

      def students
        assignment.context.students
      end

      def students_with_submissions
        assignment.submissions.map do |submission|
          submission.student if submission.workflow_state == 'submitted' or submission.workflow_state == 'graded' or !submission.score.nil? or !submission.grade.nil?
        end.compact
      end

      def students_without_submissions
        students.select { |s| students_with_submissions.exclude?(s) }
      end
    end
  end
end
