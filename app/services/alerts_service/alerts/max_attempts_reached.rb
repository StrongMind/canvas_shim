module AlertsService
  module Alerts
    class MaxAttemptsReached
      def self.alert_attributes
        [:teacher_id, :student_id, :assignment_id, :score]
      end

      include AlertBuilder

      def assignment
        Assignment.find(assignment_id)
      end

      def student
        User.find(student_id)
      end

      def type
        'Max Attempts Reached'
      end
    end
  end
end