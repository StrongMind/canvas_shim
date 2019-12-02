module ExcusedService
  module Commands
    class SendUnassignContext
      def initialize(assignment:, new_unassigns:, timestamp:, grader_id:)
        @assignment = assignment
        @new_unassigns = new_unassigns
        @timestamp = timestamp
        @grader_id = grader_id
      end

      def performable?
        assignment && new_unassigns
      end

      def previous_unassigns
        (ExcusedService.unassigned_students(@assignment) || "").split(",")
      end

      def previous_unassign_context
        setting = SettingsService.get_settings(
                    object: :assignment,
                    id: "#{assignment.id}"
                  )['unassign_context']

        return JSON.parse(setting) if setting
        {}
      end

      def cleaned_previous_context
        previous_unassign_context.each do |ts, unassign_group|
          if unassign_group[:unassigns]
            clean_unassign_group(group)
          end
        end
      end

      def clean_unassign_group(group)
        group.reject! { |id| reassigned_student?(id) }
      end

      def reassigned_student?(id)
        previous_unassigns.include?(id) && !new_unassigns.include?(id)
      end

      def new_unassign_context
        {
          @timestamp => {
            grader_id: @grader_id,
            unassigns: @new_unassigns
          }
        }
      end

      def merged_unassigns
        cleaned_previous_context.merge(new_unassign_context)
      end

      def perform
        return unless performable?

        SettingsService.update_settings(
          object: 'assignment',
          id: @assignment.id,
          setting: 'unassign_context',
          value: merged_unassigns.to_json
        )

        PipelineService.publish(PipelineService::Nouns::Unassigned.new(@assignment))
      end
    end
  end
end