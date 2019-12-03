module PipelineService
  module Serializers
    class Unassigned
      attr_reader :assignment, :id
      def initialize object:
        @assignment = object
        @id = assignment.id
      end

      def call
        @payload = {
          assignment_id: id,
          unassigned_students: unassigned_students
        }.to_json
      end

      def unassigned_students
        setting = SettingsService.get_settings(
                    object: :assignment,
                    id: "#{id}"
                  )['unassign_context']

        setting ? JSON.parse(setting) : {}
      end
    end
  end
end

