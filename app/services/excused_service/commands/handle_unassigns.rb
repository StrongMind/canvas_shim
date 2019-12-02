module ExcusedService
  module Commands
    class HandleUnassigns
      def initialize(assignment:, assignment_params:, grader_id:)
        @assignment = assignment
        @assignment_params = assignment_params
        @new_unassigns = extract_ids_from_bulk_unassign
        @previous_unassigns = ExcusedService.unassigned_students(assignment)
        @grader_id = grader_id
      end

      def call
        return unless all_objects_present?
        send_original_due_date if assignment.due_at
        send_unassigns_to_settings
        send_unassign_context
        remove_unassigns_from_overrides
        remove_scores_from_unassigns
        override_originally_assigned_students
        assignment_params[:only_visible_to_overrides] = true
      end

      private
      attr_reader :assignment, :assignment_params, :new_unassigns, :previous_unassigns, :grader_id

      def all_objects_present?
        assignment && assignment_params && new_unassigns && needs_to_change?
      end

      def needs_to_change?
        new_unassigns.any? || previous_unassigns
      end

      def send_original_due_date
        SettingsService.update_settings(
          object: 'assignment',
          id: "#{assignment.id}",
          setting: 'original_due_date',
          value: assignment.due_at.to_s
        )
      end

      def send_unassigns_to_settings
        @sent_unassigns = all_unassigns.blank? ? false : all_unassigns.join(",")
        SettingsService.update_settings(
          object: 'assignment',
          id: "#{assignment.id}",
          setting: 'unassigned_students',
          value: @sent_unassigns
        )
        PipelineService.publish(PipelineService::Nouns::Unassigned.new(assignment))
      end

      def send_unassign_context
        ExcusedService.send_unassign_context(
          assignment: assignment,
          new_unassigns: new_not_previous,
          previous_unassigns: formatted_previous_unassigns,
          grader_id: grader_id
        )
      end

      def remove_unassigns_from_overrides
        assignment_params[:assignment_overrides].each do |override|
          if override["student_ids"]
            override["student_ids"].delete_if { |st_id| new_unassigns.include?(st_id) }
          end
        end
      end

      def remove_scores_from_unassigns
        new_unassigns.each do |student_id|
          submission = Submission.find_by(
            assignment_id: assignment.id,
            user_id: student_id
          )

          submission.update(score: nil) if submission
        end
      end

      def override_originally_assigned_students
        current_override = same_time_override
        if current_override
          current_override["student_ids"].concat(students_to_be_overridden)
        else
          add_new_override
        end
      end

      def same_time_override
        assignment_params[:assignment_overrides].find do |override|
          override["due_at"]&.to_datetime == original_due_date&.to_datetime
        end
      end

      def students_to_be_overridden
        assignment.course.active_or_invited_students.where(
          "user_id NOT IN (?)", skipped_student_ids
        ).pluck(:user_id).map(&:to_s)
      end

      def skipped_student_ids
        all_unassigns.concat(existing_assignment_overrides).uniq
      end

      def all_unassigns
        @all_unassigns ||= conjoin_unassigned_students
      end

      def conjoin_unassigned_students
        if previous_unassigns
          persisted_and_new_unassigns
        elsif new_unassigns.any?
          new_unassigns
        else
          []
        end
      end

      def persisted_and_new_unassigns
        persisted = previous_unassigns.split(",").select { |un| new_unassigns.include?(un) }
        persisted.concat(new_not_previous).uniq
      end

      def new_not_previous
        new_unassigns.reject { |un| formatted_previous_unassigns.include?(un) }
      end

      def formatted_previous_unassigns
        (previous_unassigns || "").split(",")
      end

      def existing_assignment_overrides
        ov_ids = assignment_params[:assignment_overrides].flat_map { |ao| ao[:student_ids] }
        return ov_ids unless previous_unassigns
        ov_ids.reject { |id| reassigned_student?(id) }
      end

      def reassigned_student?(id)
        formatted_previous_unassigns.include?(id) && !new_unassigns.include?(id)
      end

      def original_due_date
        SettingsService.get_settings(
          object: :assignment,
          id: "#{assignment.id}"
        )['original_due_date']
      end

      def add_new_override
        assignment_params[:assignment_overrides] << {
          "due_at"=> original_due_date,
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

      def extract_ids_from_bulk_unassign
        full_list = assignment_params&.fetch(:bulk_unassign, nil)
        return unless full_list
        full_list.map { |student| student[:id] }
      end
    end
  end
end