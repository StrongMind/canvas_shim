module GradesService
  module Commands
    class ZeroOutAssignmentGrades
      def initialize(assignment)
        @assignment = assignment
      end

      def call!
        return unless ENV['ZERO_OUT_PASTDUE_ASSIGNMENTS'] and ENV['ZERO_OUT_PASTDUE_ASSIGNMENTS'].downcase == "true"
        return unless assignment.published?
        return if still_submittable?
        grade_students
      end

      private

      attr_reader :assignment

      def grade_students
        students_without_submissions.each do |student|
          assignment.grade_student(student, score: 0, grader: grader)
        end
      end

      def grader
        GradesService::Account.account_admin
      end

      def still_submittable?
        return if assignment.due_date.nil?
        assignment.due_date > 1.hour.ago
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
