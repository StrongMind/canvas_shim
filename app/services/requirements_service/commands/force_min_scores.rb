module RequirementsService
  module Commands
    class ForceMinScores
      def initialize(course:, assignment_group_names:)
        @course = course
        @assignment_group_names = assignment_group_names
      end

      def call
        Delayed::Job.enqueue(self)
      end

      def perform
        @course.try(:force_min_scores, assignment_group_names: @assignment_group_names)
      end
    end
  end
end