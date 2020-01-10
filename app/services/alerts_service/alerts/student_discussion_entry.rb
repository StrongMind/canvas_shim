module AlertsService
  module Alerts
    class StudentDiscussionEntry < Alert
      ALERT_ATTRIBUTES = %i{ teacher_id student_id assignment_id score course_id}

      def initialize(atts)
        super
      end

      def assignment
        Assignment.find(assignment_id)
      end

      def student
        User.find(student_id)
      end

      def detail
        return unless @score.present?
        "Last Score: #{@score}"
      end

      def description
        'Max Attempts & Minimum Score Not Reached'
      end
    end
  end
end