module AlertsService
  module Alerts
    class MaxAttemptsReached
      def self.required_attributes
        [:teacher_id, :student_id, :assignment_id]
      end

      include PayloadBuilder

      def initialize(teacher_id:, student_id:, assignment_id:)
        @teacher_id = teacher_id
        @student_id = student_id
        @assignment_id = assignment_id
      end

      def as_json
        {
          teacher_id: teacher_id,
          student_id: student_id,
          assignment_id: assignment_id,
          type: type
        }
      end

      def type
        'max_attempts_reached'
      end
    end
  end
end