module AlertsService
  module Alerts
    class MaxAttemptsReached
      ALERT_ATTRIBUTES = [:teacher_id, :student_id, :assignment_id, :score]
      TYPE = 'Max Attempts Reached'
      include AlertBuilder

      def assignment
        Assignment.find(assignment_id)
      end

      def student
        User.find(student_id)
      end

      def type
        
      end
    end
  end
end