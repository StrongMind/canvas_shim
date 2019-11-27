module PipelineService
  module Serializers
    class Unassigned
      attr_reader :assignment, :id
      def initialize object:
        @assignment = object
        @id = assignment.id
      end

      def call
        unassigned_student_ids

        @payload = {
          assignment_id: @assignment.id,
          unassigned_students: unassigned_student_ids
      }.to_json
      end

      def unassigned_student_ids
        unassigned_students = SettingsService.get_settings(
          object: 'assignment',
          id: @assignment.id.to_s,
        )['unassigned_students']
        unless unassigned_students.empty?
          unassigned_students.split(",").map { |s| s.to_i } 
        else
          []
        end
      end
    end
  end
end

