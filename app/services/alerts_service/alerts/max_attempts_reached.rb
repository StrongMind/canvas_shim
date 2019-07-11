module AlertsService
  module Alerts
    class MaxAttemptsReached
      ALERT_ATTRIBUTES = %i{teacher_id student_id assignment_id score}
      TYPE = 'Max Attempts Reached'
      
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
    end
  end
end