module CoursesService
  module Commands
    class DistributeDueDates
      def initialize(args)
        @course = args[:course]
        @startdate = course.start_at
        @enddate = course.end_at
        @assignments_per_day = (assignments.count / course_days_count).to_i
      end

      def call
        assignment_groups.each.with_index do |assignment_group, i|
          update_assignments(assignment_group, course_days[i])
        end
      end

      private

      attr_reader :course, :startdate, :enddate, :assignments_per_day

      def update_assignments(assignment_group, day)
        assignment_group.each { |assignment| assignment.update(due_at: day) }
      end

      def assignment_groups
        assignments.in_groups_of(assignments_per_day, false)
      end

      def assignments
        content_tags.map { |tag| tag.assignment }
      end

      def content_tags
        ContentTag
          .where(content_type: 'Assignment', context_id: course.id)
          .order(:position)
      end

      def calendar
        Business::Calendar.new(working_days: %w( mon tue wed thu fri ))
      end

      def course_days
        course_days_count.times.map do |i|
          day = startdate + i.days
          day unless !calendar.business_day?(day)
        end.compact
      end

      def course_days_count
        calendar.business_days_between(startdate, enddate)
      end
    end
  end
end
