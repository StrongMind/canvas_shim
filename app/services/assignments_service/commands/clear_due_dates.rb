module AssignmentsService
  module Commands
    class ClearDueDates
      def initialize(course:)
        @assignments = course.try(:assignments)
        @course_assignments = assignments
      end

      def perform
        call
      end

      def call
        return unless assignments
        assignments.each { |asn| asn.update(due_at: nil) }
      end

      private
      attr_reader :assignments
    end
  end
end