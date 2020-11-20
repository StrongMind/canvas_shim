module AssignmentsService
  module Commands
    class DistributeDueDates
      def initialize(args)
        @args = args
        @course = args[:course]
        @assignment_query = Queries::AssignmentsWithDueDates.new(course: @course)
        @course_assignments = assignments
        @progress = create_progress!
      end

      def call
        return unless SettingsService.get_settings(object: :school, id: 1)['auto_due_dates'] == 'on'
        return unless course.start_at && course.end_at
        distribute
      end

      def perform
        return unless course.start_at && course.end_at
        distribute
      end

      private
      attr_reader :course, :course_assignments, :assignments_per_day, :progress

      def create_progress!
        @course.progresses.create!(tag: "distribute_due_dates", workflow_state: "running")
      end

      def distribute_with_progress
        begin
          distribute
        rescue
          progress.update(workflow_state: "failed")
        end
      end

      def distribute
        offset = 0
        initial_slice = course_assignments_size_to_f
        scheduler.course_dates.each do |date, count|

          if count.zero?
            offset += 1
            next
          else
            offset = 0
          end

          update_assignments(course_assignments.slice!(offset..count - 1), date)
          reverse_calculate_completion!(course_assignments_size_to_f, initial_slice)
        end

        progress.update_completion!(100)
        progress.update(workflow_state: "complete")
      end

      def course_assignments_size_to_f
        course_assignments.size.to_f
      end

      def reverse_calculate_completion!(current_value, total)
        progress.update_completion!(100 - (100.0 * current_value / total))
      end

      def scheduler
        @scheduler ||= Scheduler.new(@args.merge(assignment_count: assignments.count))
      end

      def update_assignments(assignments_for_day, date)
        assignments_for_day.each do |assignment|
          next if assignment.nil?
          assignment.update(due_at: date)
          AssignmentsService.handle_overrides(assignment: assignment, due_at: date)
        end
      end

      def assignments
        @assignment_query.query
      end

      def clear_due_dates(course_assignments)
        course_assignments.each do |asst|
          asst.update(due_at: nil)
        end
      end
    end
  end
end
