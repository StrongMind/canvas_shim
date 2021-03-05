module AlertsService
  module Alerts
    class SubmissionNeedsRegrading < Alert
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
        "Last Score: %g" % ("%.2f" % score)
      end

      def description
        'Submission Needs Regrading'
      end
    end
  end
end
