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

      def calculate_grades
        # @course.assignment_groups.map{|ag| [ag.group_weight, ag.name]}

        result = {}

        @unit_submissions.each do |unit, submissions|
          next if submissions.count == 0

          filtered = submissions.select do |submission|
            !submission.excused?
          end

          result[unit.id] = filtered.sum(&:score) / filtered.count
        end

        result
      end
    end
  end
end
