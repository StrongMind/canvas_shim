module UnitsService
  module Queries
    class GetSubmissions
      def initialize(course:, student:)
        @student = student
        @course = course
      end

      def query
        result = {}
        units.each do |unit, items|
          items.each do |item|
            result[unit] = item.content.submissions.where(user_id: @student.id).where("excused is not true")
          end
        end

        result
      end

      def units
        GetItems.new(course: @course).query
      end
    end
  end
end
