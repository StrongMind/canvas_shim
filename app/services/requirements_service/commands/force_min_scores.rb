module RequirementsService
  module Commands
    class ForceMinScores
      def initialize(course:)
        @course = course
      end

      def call
        Delayed::Job.enqueue(self)
      end

      def perform
        @course.try(:force_min_scores)
      end
    end
  end
end
