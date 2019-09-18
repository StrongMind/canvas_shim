module ExcusedService
  module Commands
    class HandleUnassigns
      def initialize(assignment:, assignment_params:)
        @assignment = assignment
        @assingment_params = assignment_params
        @new_unassigns = assignment_params&.fetch(:bulk_unassign, nil)
        @previous_unassigns = SettingsService.get_settings(
                                object: :assignment,
                                id: assignment.id
                              )['unassigned_students']
      end

      def call
        return unless all_objects_present?
        send_unassigns_to_settings
        return unless @all_unassigns
        # mutate assignment_params[:assignment_overrides]
        # assignment_params[:only_visible_to_overides] = true
      end

      private
      attr_reader :assignment, :assignment_params, :new_unassigns, :previous_unassigns

      def all_objects_present?
        assignment && assignment_params && new_unassigns
      end

      def send_unassigns_to_settings
        @all_unassigns = conjoin_unassigned_students
        @sent_unassigns = @all_unassigns.blank? ? false : @all_unassigns.join(",")
        SettingsService.update_settings(
          object: 'assignment',
          id: assignment.id,
          setting: 'unassigned_students',
          value: @sent_unassigns
        )
      end

      def conjoin_unassigned_students
        if previous_unassigns
          previous_unassigns.split(",").select do |unassign|
            new_unassigns.include?(unassign)
          end
        elsif new_unassigns.any?
          new_unassigns
        else
          []
        end
      end

      def filter_out_overrides_and_new_unassigns
        assignment.course.users.where(
          "id NOT IN (?)", skipped_student_ids
        )
      end

      def existing_assignment_overrides
        assignment.assignment_overrides.pluck(:student_id)
      end

      def skipped_student_ids
        @all_unassigns.map(&:to_i).concat(existing_assignment_overrides)
      end
    end
  end
end