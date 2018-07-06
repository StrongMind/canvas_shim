module CoursesService
  module Commands
    class DistributeDueDates
      class Scheduler
        def initialize(args = {})
          @startdate = args[:course].start_at
          @enddate = args[:course].end_at
          @assignment_count = args[:assignment_count]
        end

        def assignments_per_day
          assignment_count / course_days_count
        end

        # Business Days
        def course_dates
          course_days_count.times.map do |i|
            day = startdate + i.days
            day if calendar.business_day?(day)
          end.compact
        end

        def course_days_count
          calendar.business_days_between(startdate, enddate)
        end

        private

        attr_reader :assignment_count, :startdate, :enddate

        def calendar
          Business::Calendar.new(working_days: %w( mon tue wed thu fri ))
        end
      end
    end
  end
end
