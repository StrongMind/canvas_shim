module CoursesService
  module Commands
    class DistributeDueDates
      def initialize(args)
        @course = args[:course]
        @startdate = course.start_at
        @enddate = course.end_at
        @assignments_per_day = (assignments.count / course_days).to_i
        @course_day = 1
      end

      def call
        assignment_groups.each do |assignment_group|
          skip_weekends
          update_assignments(assignment_group)
          @course_day += 1 if day_within_course?
        end
      end

      private

      attr_reader :course, :startdate, :enddate, :assignments_per_day

      def update_assignments(assignment_group)
        assignment_group.each do |assignment|
          assignment.update(due_at: startdate + @course_day.day)
        end
      end

      def skip_weekends
        while weekend? && day_within_course?(@course_day) do
          @course_day += 1
        end
      end

      def day_within_course?
        @course_day < course_days
      end

      def weekend?
        !calendar.business_day?(startdate + @course_day.day)
      end

      def assignment_groups
        assignments.in_groups_of(assignments_per_day, false)
      end

      def assignments
        ContentTag.where(
          content_type: 'Assignment',
          context_id: course.id
        ).order(:position).map { |tag| tag.assignment }
      end

      def calendar
        Business::Calendar.new(working_days: %w( mon tue wed thu fri ))
      end

      def course_days
        calendar.business_days_between(startdate, enddate)
      end
    end
  end
end
