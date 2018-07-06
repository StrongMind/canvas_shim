module CoursesService
  module Commands
    class DistributeDueDates
      class Scheduler
        def initialize(args = {})
          @args = args
          @startdate = first_due_date
          @enddate = args[:course].end_at
          @assignment_count = args[:assignment_count]
        end

        def assignments_per_day
          (assignment_count / course_days_count)
        end

        def course_dates
          days = course_days_count.times.map do |count|

            day = startdate + (count).days
            day if calendar.business_day?(day)
          end.compact

          result = {}

          days.each do |day|
            result[day] = assignments_per_day
          end

          remainder = assignment_count % course_days_count

          remainder.times.each do |num|
            result[days[num]] = result[days[num]] + 1
          end

          result
        end

        def course_days_count
          calendar.business_days_between(startdate, enddate)
        end

        private

        attr_reader :assignment_count, :startdate, :enddate

        def first_due_date
          @args[:course].start_at + 1
        end

        def calendar
          Business::Calendar.new(working_days: %w( mon tue wed thu fri ))
        end
      end
    end
  end
end
