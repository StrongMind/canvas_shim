module CoursesService
  module Commands
    class DistributeDueDates
      def initialize(args)
        @args = args
        @course = args[:course]
      end

      def call
        scheduler.course_dates.each do |date, count|
          update_assignments(assignments.slice!(0..count - 1), date)
        end
      end

      private

      attr_reader :course, :startdate, :enddate, :assignments_per_day

      def scheduler
        @scheduler ||= Scheduler.new(@args.merge(assignment_count: assignments.count))
      end

      def update_assignments(assignments_for_day, date)
        assignments_for_day.each { |assignment| assignment.update(due_at: date) }
      end

      def assignments
        @assignments ||= ContentTag
          .where(content_type: 'Assignment', context_id: course.id)
          .order(:position)
          .map { |tag| tag.assignment }
      end
    end
  end
end
