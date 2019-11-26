module PipelineService
  module Serializers
    class Unassigned
      def initialize object:
        @assignment = object
      end

      def call
        unassigned_student_ids

        @payload = {
          assignment_id: @assignment.id,
          unassigned_students: unassigned_student_ids.map {|id| {student_id: id, unassigned_at: AssignmentOverrideStudent.find_by(user_id: id, assignment_id: @assignment.id).try(:created_at).iso8601} }
      }.to_json
      end

      private

      attr_reader :assignment



      def unassigned_student_ids
        unassigned_students = SettingsService.get_settings(
          object: 'assignment',
          id: "160771"
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



