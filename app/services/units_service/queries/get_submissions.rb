module UnitsService
  module Queries
    class GetSubmissions
      def initialize(course:, student:)
        @student = student
        @course = course
      end

      def query
        units = GetItems.new(course: @course).query

        result = {}

        units.each do |unit, items|
          items.each do |item|
            result[unit] = item.content.submissions.where(user_id: @student.id)
          end
        end

        byebug
        result
      end
    end
  end
end
