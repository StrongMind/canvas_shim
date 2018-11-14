module UnitsService
  module Queries
    class GetCategoryWeights
      def initialize(course)
        @course = course
      end

      def query
        @course.assignment_groups.map{|ag| [ag.name, ag.group_weight]}.to_h
      end
    end
  end
end
