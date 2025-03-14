module GradesService
  module Queries
    class ZeroGraderSubmissions
      def initialize
        @zero_grader_start_date = SettingsService.get_settings(object: :school, id: 1)['zero_out_start_date']
      end

      def query
        submissions_scope
        start_date_scope if zero_grader_start_date
        scope
      end

      private

      attr_accessor :scope, :zero_grader_start_date

      def submissions_scope
        @scope = Submission
          .joins(assignment: :course)
          .where(score: nil)
          .where(grade: nil)
          .where('submissions.cached_due_date < ?', 1.hour.ago)
          .where('courses.conclude_at > ?', 2.days.ago)
          .where('assignments.workflow_state = ?', 'published')
      end

      def start_date_scope
        @scope = scope.where('courses.start_at >= ?', zero_grader_start_date)
      end
    end
  end
end
