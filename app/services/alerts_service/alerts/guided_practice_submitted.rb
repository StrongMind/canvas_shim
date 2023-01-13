module AlertsService
  module Alerts
    class GuidedPracticeSubmitted < Alert
      ALERT_ATTRIBUTES = %i{ teacher_id student_id assignment_id course_id}

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
        "Guided Practice Submitted"
      end

      def description
        'Guided Practice Submitted'
      end
    end
  end
end
