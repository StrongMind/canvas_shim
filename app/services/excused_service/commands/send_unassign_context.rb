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
        self.previous_context = previous_unassign_context
        clean_previous_context

        SettingsService.update_settings(
          object: 'assignment',
          id: "#{assignment.id}",
          setting: 'unassign_context',
          value: merged_unassigns.to_json
        )

        PipelineService.publish(PipelineService::Nouns::Unassigned.new(assignment))
      end

      private

      attr_reader :assignment, :new_unassigns, :previous_unassigns, :grader_id, :timestamp
      attr_accessor :previous_context

      def performable?
        assignment && timestamp
      end

      def previous_unassign_context
        setting = SettingsService.get_settings(
                    object: :assignment,
                    id: "#{assignment.id}"
                  )['unassign_context']

        return JSON.parse(setting) if setting
        previous_unassigns.any? ? legacy_unassign_context : {}
      end

      def legacy_unassign_context
        {
          "" => {
            grader_id: nil,
            unassigns: previous_unassigns
          }
        }
      end

      def clean_previous_context
        previous_context.each do |ts, unassign_group|
          if unassign_group["unassigns"]
            clean_unassigns(unassign_group["unassigns"])
          end
        end
      end

      def clean_unassigns(group)
        group.select! { |id| still_unassigned_student?(id) }
      end

      def still_unassigned_student?(id)
        (ExcusedService.unassigned_students(assignment) || "").split(",").include?(id)
      end

      def new_unassign_context
        {
          timestamp => {
            "grader_id" => grader_id,
            "unassigns" => new_unassigns
          }
        }
      end

      def merged_unassigns
        if new_unassigns.any?
          previous_context.merge(new_unassign_context)
        else
          previous_context
        end
      end
    end
  end
end