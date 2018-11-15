module UnitsService
  module Commands
    class GetUnitGrades
      def initialize(course:, student:)
        @course = course
        @student = student
      end

      def call
        get_submissions
        calculate_grades
        payload
      end

      private

      def get_submissions
        @unit_submissions = UnitsService::Queries::GetSubmissions.new(
          course: @course,
          student: @student
        ).query
      end

      def payload
        {
          school_domain: ENV['CANVAS_DOMAIN'],
          course_id: @course.id,
          student_id: @student.id,
          units: @grades.map {|unit, score| {
            id: unit.id,
            position: unit.position,
            created_at: unit.created_at,
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
