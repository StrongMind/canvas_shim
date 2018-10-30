module UnitsService
  module Commands
    class GetUnitGrades
      def initialize(course:, student:)
        @course = course
        @stuent = student
      end

      def call
        get_submissions
        calculate_grades
      end

      private

      def get_submissions
        @submissions = UnitsService::Queries::GetSubmissions.new(
          course: @course,
          student: @student
        ).query
      end

      def calculate_grades
        result = {}

        @submissions.each do |unit, submissions|
          result[unit.id] = submissions.sum(&:score) / submissions.count
        end

        result
      end
    end
  end
end
