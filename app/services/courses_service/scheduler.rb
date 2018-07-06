module CoursesService
  class Scheduler
    def initialize(args = {})
      @startdate = args[:start_date]
      @enddate = args[:end_date]
      @assignment_count = args[:assignment_count]
    end

    def assignments_per_day
      assignment_count / course_days_count
    end

    def course_dates
      course_days_count.times.map do |i|
        day = startdate + i.days
        day unless !calendar.business_day?(day)
      end.compact
    end

    private

    attr_reader :assignment_count, :startdate, :enddate

    def course_days_count
      calendar.business_days_between(startdate, enddate)
    end

    def calendar
      Business::Calendar.new(working_days: %w( mon tue wed thu fri ))
    end
  end
end
