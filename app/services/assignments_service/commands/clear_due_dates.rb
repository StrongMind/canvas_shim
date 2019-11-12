module AssignmentsService
  module Commands
    class ClearDueDates
      def initialize(course:)
        @course = course
        @assignments = course.try(:assignments)
        @course_assignments = assignments
      end

      def perform
        AssignmentsService.toggle_distribution_state(course, true)
        call
        AssignmentsService.toggle_distribution_state(course, false)
      end

      def call
        return unless assignments
        assignments.each { |asn| asn.update(due_at: nil) }
      end

      private
      attr_reader :course, :assignments
    end
  end
end