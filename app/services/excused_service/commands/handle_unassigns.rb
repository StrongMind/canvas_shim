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
        override_originally_assigned_students
        assignment_params[:only_visible_to_overrides] = true
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

      def students_to_be_overridden
        assignment.course.users.where(
          "id NOT IN (?)", skipped_student_ids
        ).pluck(:id).map(&:to_s)
      end

      def skipped_student_ids
        @all_unassigns.map(&:to_i).concat(existing_assignment_overrides)
      end

      def existing_assignment_overrides
        assignment.assignment_overrides.flat_map do |ao|
          ao.assignment_override_students.pluck(:user_id)
        end
      end

      def override_originally_assigned_students
        assignment_params[:assignment_overrides] = {
          "due_at"=> assignment_params[:due_at],
          "due_at_overridden"=> true,
          "lock_at"=> nil,
          "lock_at_overridden"=> false,
          "unlock_at"=> nil,
          "unlock_at_overridden"=>false,
          "rowKey"=>"",
          "student_ids"=> students_to_be_overridden,
          "all_day"=> false,
          "all_day_date"=> nil,
          "persisted"=> false
        }
      end
    end
  end
end