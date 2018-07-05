require 'business'
module CoursesService
  module Commands
    class DistributeDueDates
      def initialize(course)
        @course = course
        @startdate = course.start_at
        @enddate = course.end_at
        @assignments_per_day = (assignments.count / business_days).to_i
      end

      def call
        day = 1
        assignments.in_groups_of(assignments_per_day, false).each do |assignment_group|
          while !calendar.business_day?(startdate + day.day) && day < business_days do
            day = day + 1
          end

          assignment_group.each do |assignment|
            assignment.update(due_at: startdate + day.day)
          end

          day = day + 1
        end
      end

      private

      attr_reader :course, :startdate, :enddate, :assignments_per_day

      def assignments
        ContentTag.where(
          content_type: 'Assignment',
          context_id: Course.first.id
        ).order(:position).map {|tag| tag.assignment }
      end

      def calendar
        Business::Calendar.new(working_days: %w( mon tue wed thu fri ))
      end

      def business_days
        calendar.business_days_between(startdate, enddate)
      end

    end
  end
end
