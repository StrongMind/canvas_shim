module CoursesService
  module Commands
    class DistributeDueDates
      def initialize(args)
        @course = args[:course]
      end

      def call
        assignment_groups.each.with_index do |assignments_for_day, i|
          update_assignments(assignments_for_day, scheduler.course_dates[i])
        end
      end

      private

      attr_reader :course, :startdate, :enddate, :assignments_per_day

      def scheduler
        @scheduler ||= Scheduler.new(
          assignment_count: assignments.count,
          start_date: course.start_at,
          end_date: course.end_at
        )
      end

      def update_assignments(assignments_for_day, date)
        assignments_for_day.each { |assignment| assignment.update(due_at: date) }
      end

      def assignment_groups
        assignments.in_groups_of(scheduler.assignments_per_day, false)
      end

      def assignments
        ContentTag
          .where(content_type: 'Assignment', context_id: course.id)
          .order(:position)
          .map { |tag| tag.assignment }
      end
    end
  end
end
