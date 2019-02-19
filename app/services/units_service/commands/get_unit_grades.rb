module UnitsService
  module Commands
    class GetUnitGrades
      def initialize(course:, student:, submission:)
        @course = course
        @student = student
        @submission = submission
      end

      def call
        get_sis_user_id
        get_submissions
        calculate_grades
        payload
      end

      private

      def get_sis_user_id
        @sis_user_id = nil && return unless @student.respond_to?(:pseudonym)
        @sis_user_id = @student.pseudonym.try(:sis_user_id)
      end

      def get_submissions_query
        UnitsService::Queries::GetSubmissions
      end

      def get_submissions
        @unit_submissions = get_submissions_query.new(
          course: @course,
          student: @student
        ).query
      end

      def student_enrollment        
        UnitsService::Queries::GetEnrollment.query(
          course: @course, 
          user: @student
        )
      end

      def payload
        {
          school_domain: ENV['CANVAS_DOMAIN'],
          course_id: @course.id,
          course_score: student_enrollment.computed_current_score,
          student_id: @student.id,
          sis_user_id: @sis_user_id,
          submitted_at: @submission.submitted_at,
          units: @grades.map {|unit, score| {
            id: unit.id,
            position: unit.position,
            score: score
          }}
        }
      end

      def calculate_grades
        @grades = UnitsService::GradesCalculator.new(@unit_submissions, @course).call
      end
    end
  end
end
