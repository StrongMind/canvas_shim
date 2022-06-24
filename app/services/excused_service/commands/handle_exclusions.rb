module ExcusedService
  module Commands
    class HandleExclusions
      def initialize(assignment:, exclusions:)
        @assignment = assignment
        @exclusions = exclusions
      end

      def call
        handle_exclusions
      end

      private
      attr_reader :assignment, :exclusions

      def handle_exclusions
        if assignment && exclusions
          begin
            Assignment.transaction do
              exclusions.each do |student|
                assignment.toggle_exclusion(student['id'].to_i, true)
              end
              unexcuse_assignments
            end
          rescue StandardError => exception
            Sentry.capture_exception(exception)
          end
        end
      end

      def unexcuse_assignments
        student_ids = exclusions.map { |student| student['id'] }
        excused = assignment.excused_submissions
        excused = excused.where("user_id NOT IN (?)", student_ids) if student_ids.any?
        excused.each do |sub|
          assignment.toggle_exclusion(sub.user_id, false)
        end
      end
    end
  end
end
