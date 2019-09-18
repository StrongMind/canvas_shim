module ExcusedService
  module Commands
    class HandleUnassigns
      def initialize(assignment:, assignment_params:)
        @assignment = assignment
        @assingment_params = assignment_params
        @new_unassigns = assignment_params&.fetch(:bulk_unassign, nil)
      end

      def call
        return unless all_objects_present?
        send_unassigns_to_settings
        # mutate assignment_params[:assignment_overrides]
        # assignment_params[:only_visible_to_overides] = true
      end

      private
      attr_reader :assignment, :assignment_params, :new_unassigns

      def all_objects_present?
        assignment && assignment_params && new_unassigns
      end

      def send_unassigns_to_settings
        @all_unassigns = conjoin_unassigned_students(
                           assignment_params[:bulk_unassign]
                         )
        @all_unassigns = @all_unassigns.blank? ? false : @all_unassigns.join(",")
        SettingsService.update_settings(
          object: 'assignment',
          id: assignment.id,
          setting: 'unassigned_students',
          value: @all_unassigns
        )
      end

      def conjoin_unassigned_students
        if unassigned_students
          current_unassigns = unassigned_students.split(",")
          return current_unassigns unless new_unassigns.any?
          current_unassigns.concat(new_unassigns).uniq
        elsif new_unassigns.any?
          new_unassigns
        else
          []
        end
      end
    end
  end
end