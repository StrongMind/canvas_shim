module GradesService
  module Commands
    class ZeroOutAssignmentGrades
      def initialize(assignment)
        @assignment = assignment
      end

      def call!
        return if not_past_due?
        students_without_submissions.each do |student|
          assignment.grade_student(student, score: 0, grader: grader)
        end
      end

      private

      attr_reader :assignment

      def grader
        Account.account_admin
      end

      def not_past_due?
        return unless assignment.due_date
        (1.hour.ago < assignment.due_date )
      end

      def students
         assignment.context.students
      end

      def students_with_submissions
        assignment.submissions.map {|s| s.student}
      end

      def students_without_submissions
        students.select {|s| students_with_submissions.exclude?(s) }
      end
    end
  end
end
