module AssignmentsService
  module Commands
    class ClearDueDates
      def initialize(course:)
        @course = course
        @assignments = course.try(:assignments)
        @course_assignments = assignments
      end

      def perform
        AssignmentsService.dist_on(course)
        call
        AssignmentsService.dist_off(course)
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