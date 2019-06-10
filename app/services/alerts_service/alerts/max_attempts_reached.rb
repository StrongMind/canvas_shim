module AlertsService
  module Alerts
    class MaxAttemptsReached
      def self.required_attributes
        [:teacher_id, :student_id, :assignment_id]
      end

      include AlertBuilder

      def initialize(teacher_id:, student_id:, assignment_id:)
        @teacher_id = teacher_id
        @student_id = student_id
        @assignment_id = assignment_id
      end

      def type
        'max_attempts_reached'
      end
    end
  end
end