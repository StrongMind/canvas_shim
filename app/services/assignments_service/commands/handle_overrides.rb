module AssignmentsService
  module Commands
    class HandleOverrides
      def initialize(assignment:, due_at:)
        @assignment = assignment
        @due_at = due_at
        @overrides = assignment.try(:assignment_overrides)
      end

      def call
        return unless assignment && overrides.try(:any?)
        if assignment.only_visible_to_overrides
          overrides.update_all(due_at: due_at)
        else
          overrides.destroy_all
        end
      end

      private
      attr_reader :assignment, :due_at, :overrides
    end
  end
end