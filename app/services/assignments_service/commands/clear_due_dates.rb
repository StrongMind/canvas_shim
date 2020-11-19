module AssignmentsService
  module Commands
    class ClearDueDates
      def initialize(course:)
        @course = course
        @assignments = course.try(:assignments)
        @course_assignments = assignments
        @progress = create_progress!
      end

      def perform
        begin
          call
        rescue
          progress.update(workflow_state: "failed")
        end
      end

      def call
        return unless assignments
        total_size = assignments.size
        assignments.each_with_index do |assignment, idx|
          assignment.update(due_at: nil)
          AssignmentsService.handle_overrides(assignment: assignment, due_at: nil)
          progress.calculate_completion!(idx + 1, total_size)
        end

        progress.update(workflow_state: "completed")
      end

      private
      attr_reader :course, :assignments, :progress

      def create_progress!
        @course.progresses.create!(tag: "distribute_due_dates", workflow_state: "running")
      end
    end
  end
end