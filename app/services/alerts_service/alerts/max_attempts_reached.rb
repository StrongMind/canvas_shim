module AlertsService
  module Alerts
    class MaxAttemptsReached
      ALERT_ATTRIBUTES = %i{teacher_id student_id assignment_id score description detail}
      TYPE = 'max_attempts_reached'
      
      include AlertBuilder

      def assignment
        Assignment.find(assignment_id)
      end

      def student
        User.find(student_id)
      end

      def detail
        return unless @score.present?
        "Score: #{@score}"
      end

      def description
        'Max Attempts Reached'
      end
    end
  end
end