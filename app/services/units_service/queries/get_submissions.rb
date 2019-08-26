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
            subs = item.content.try(:submissions) ||
                  item.content.try(:assignment).submissions
            subs
              .where(user_id: @student.id).each do |submission|
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
