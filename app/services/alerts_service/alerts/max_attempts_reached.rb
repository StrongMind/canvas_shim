module AlertsService
  module Alerts
    class MaxAttemptsReached
      def self.required_attributes
        [:teacher_id, :student_id, :assignment_id, :alert_id, :created_at, :updated_at]
      end

      include AlertBuilder

      def initialize(teacher_id:, student_id:, assignment_id:, alert_id: nil, created_at: nil, updated_at: nil)
        @teacher_id = teacher_id
        @student_id = student_id
        @assignment_id = assignment_id
        @alert_id = alert_id
      end

      def type
        'max_attempts_reached'
      end
    end
  end
end