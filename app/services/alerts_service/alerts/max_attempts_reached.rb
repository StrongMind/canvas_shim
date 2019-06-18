module AlertsService
  module Alerts
    class MaxAttemptsReached
      def self.required_attributes
        [:teacher_id, :student_id, :assignment_id]
      end

      include AlertBuilder

      def initialize(teacher_id:, student_id:, assignment_id:, alert_id: nil, created_at: nil, updated_at: nil)
        @teacher_id = teacher_id
        @student_id = student_id
        @assignment_id = assignment_id
        @created_at = created_at
        @updated_at = updated_at
        @alert_id = alert_id
      end

      def assignment
        Assignment.find(assignment_id)
      end

      def student
        User.find(student_id)
      end

      def type
        'Max Attempts Reached'
      end

      def created_at
        DateTime.parse(@created_at)
      end

      def updated_at
        DateTime.parse(@created_at)
      end
    end
  end
end