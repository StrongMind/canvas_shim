module AssignmentsService
  class Scheduler
    WORKING_DAYS = %w( mon tue wed thu fri )

    def initialize(args = {})
      @args = args
      @startdate = first_due_date
      @enddate = args[:course].end_at
      @assignment_count = args[:assignment_count]
    end

    def assignments_per_day
      (assignment_count / business_days_count)
    end

    def course_dates
      get_days
      populate_assignment_counts
    end

    def business_days_count
      calendar.business_days_between(startdate, enddate)
    end

    def course_days_count
      enddate.to_date.mjd - startdate.to_date.mjd
    end

    private

    attr_reader :assignment_count, :startdate, :enddate, :days

    def first_due_date
      if @args[:start_date]
        @args[:start_date].in_time_zone(@args[:course].time_zone).at_end_of_day + 1.day
      else
        @args[:course].start_at.in_time_zone(@args[:course].time_zone).at_end_of_day + 1.day
      end
    end

    def calendar
      if ENV['HOLIDAYS']
        Business::Calendar.new(working_days: WORKING_DAYS, holidays: ENV['HOLIDAYS'].split(','))
      else
        Business::Calendar.new(working_days: WORKING_DAYS)
      end

    end

    def get_days
      @days ||= course_days_count.times.map do |count|
        day = startdate + (count).days
        day if calendar.business_day?(day)
      end.compact
    end

    def populate_assignment_counts
      result = {}
      days.each do |day|
        result[day] = assignments_per_day
        byebug
      end

      (assignment_count % business_days_count).times.each do |num|
        result[days[num]] = result[days[num]] + 1
        byebug
      end

      result
    end
  end
end
