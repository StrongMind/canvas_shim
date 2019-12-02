module ExcusedService
  module Commands
    class SendUnassignContext
      def initialize(assignment:, new_unassigns:, previous_unassigns:, grader_id:, timestamp:)
        @assignment = assignment
        @new_unassigns = new_unassigns
        @previous_unassigns = previous_unassigns
        @grader_id = grader_id
        @timestamp = timestamp
      end

      def perform
        return unless performable?

        SettingsService.update_settings(
          object: 'assignment',
          id: assignment.id,
          setting: 'unassign_context',
          value: merged_unassigns.to_json
        )

        PipelineService.publish(PipelineService::Nouns::Unassigned.new(assignment))
      end

      private

      attr_reader :assignment, :new_unassigns, :previous_unassigns, :grader_id, :timestamp

      def performable?
        assignment && timestamp
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
          timestamp => {
            grader_id: grader_id,
            unassigns: new_unassigns
          }
        }
      end

      def merged_unassigns
        cleaned_previous_context.merge(new_unassign_context)
      end
    end
  end
end