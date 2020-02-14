module AlertsService
  module Alerts
    class StudentFeedback < Alert
      ALERT_ATTRIBUTES = %i{ teacher_id student_id assignment_id comment course_id}

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
        @comment
      end

      def description
        'Student commented on a assignment'
      end
    end
  end
end
