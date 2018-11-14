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
      end

      private

      def get_submissions
        @unit_submissions = UnitsService::Queries::GetSubmissions.new(
          course: @course,
          student: @student
        ).query
      end

      # {
      #   course_id: 1,
      #   student_id: 13,
      #   units: {
      #     { id: 1, score: 80 },
      #     { id: 2, grade: 83 },
      #     { id: 3, grade: 74 },
      #     { id: 4, grade: 56 },
      #     { id: 5, grade: 99 },
      #     { id: 6, grade: 12 }
      #   }
      # }
      def calculate_grades
        UnitsService::GradesCalculator.new(@unit_submissions, @course).call
      end
    end
  end
end
