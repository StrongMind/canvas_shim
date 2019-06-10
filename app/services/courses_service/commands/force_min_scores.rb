module CoursesService
  module Commands
    class ForceMinScores
      def initialize(course:)
        @course = course
      end

      def call
        Delayed::Job.enqueue(self, :priority => 0)
      end

      def perform
        @course.try(:force_min_scores)
      end
    end
  end
end