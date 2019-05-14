module AssignmentsService
  class Scheduler
    WORKING_DAYS = %w( mon tue wed thu fri )

    def initialize(args = {})
      @args = args
      @startdate = first_due_date
      @enddate = last_due_date
      @assignment_count = args[:assignment_count]
    end

    def assignments_per_day
      (assignment_count / business_days_count)
    end

    def course_dates
      get_days
      assignment_count < business_days_count ? spread_dates : populate_assignment_counts
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

    def last_due_date
      @args[:course].end_at.in_time_zone(@args[:course].time_zone).at_end_of_day - 1.day
    end

    def calendar
      if dynamo_holidays
        Business::Calendar.new(working_days: WORKING_DAYS, holidays: dynamo_holidays.split(','))
      elsif ENV['HOLIDAYS']
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
      end

      (assignment_count % business_days_count).times.each do |num|
        result[days[num]] = result[days[num]] + 1
      end

      result
    end

    def spread_dates
      result = Hash[days.map { |day| [day, 0] }]
      l_index = assignment_count - 1
      step = days.length.to_f / l_index
      (0...l_index).each do |int|
        result[days[int * step]] = 1
      end
      result[days.last] = 1
      result
    end

    def dynamo_holidays
      SettingsService.get_settings(object: :school, id: 1)['holidays']
    end
  end
end
