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
            item.content.submissions
              .where(user_id: @student.id)
              .where("excused is not true").each do |submission|
                result[unit] ||= []
                result[unit] << submission
              end
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
