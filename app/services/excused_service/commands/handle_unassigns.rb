module ExcusedService
  module Commands
    class HandleUnassigns
      def initialize(assignment:, assignment_params:)
        @assignment = assignment
        @assignment_params = assignment_params
        @new_unassigns = assignment_params&.fetch(:bulk_unassign, nil)
        @previous_unassigns = SettingsService.get_settings(
                                object: :assignment,
                                id: assignment.id
                              )['unassigned_students']
      end

      def call
        return unless all_objects_present?
        override_originally_assigned_students
        send_unassigns_to_settings
        assignment_params[:only_visible_to_overrides] = true
      end

      private
      attr_reader :assignment, :assignment_params, :new_unassigns, :previous_unassigns

      def all_objects_present?
        assignment && assignment_params && new_unassigns
      end

      def send_unassigns_to_settings
        @sent_unassigns = all_unassigns.blank? ? false : all_unassigns.join(",")
        SettingsService.update_settings(
          object: 'assignment',
          id: assignment.id,
          setting: 'unassigned_students',
          value: @sent_unassigns
        )
      end

      def all_unassigns
        @all_unassigns ||= conjoin_unassigned_students
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
        assignment.course.active_or_invited_students.where(
          "user_id NOT IN (?)", skipped_student_ids
        ).pluck(:user_id).map(&:to_s)
      end

      def skipped_student_ids
        all_unassigns.concat(existing_assignment_overrides)
      end

      def existing_assignment_overrides
        assignment_params[:assignment_overrides].flat_map { |ao| ao[:student_ids] }
      end

      def override_originally_assigned_students
        assignment_params[:assignment_overrides] << {
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