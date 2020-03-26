module AssignmentsService
  module Commands
    class ClearDueDates
      def initialize(course:)
        @course = course
        @assignments = course.try(:assignments)
        @course_assignments = assignments
      end

      def perform
        call
      end

      def call
        return unless assignments
        assignments.each do |asn|
          asn.update(due_at: nil)
          asn.assignment_overrides.destroy_all
        end
      end

      private
      attr_reader :course, :assignments
    end
  end
end