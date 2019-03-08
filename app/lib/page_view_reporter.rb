class PageViewReporter
  attr_accessor :start_date, :end_date, :dataset

  def initialize(user, course)
    @user       = user
    @course     = course

    @start_date = 7.days.ago
    @end_date   = Time.current
    @dataset    = {}
  end

  def run
    @day = @start_date.dup

    7.times do |index|
      @day += 1.day
      @page_views = PageView.for_users([@user.id])
                            .for_context(@course)
                            .where(created_at: (@day.beginning_of_day..@day.end_of_day))

      @dataset[day_key] = page_views_by_hour

      calc_databand_length
    end
  end

  def day_key
    @day.strftime("%Y-%m-%d")
  end

  # For a given day generate a 24 hour series left outer join it to page view data
  # grouped and counted by hour of date
  def dataset_for_day_of_page_views
    PageView.find_by_sql(
      <<-EOS
        SELECT day_hours.hour, COALESCE(COUNT(page_views.request_id),0) as page_views_count
        FROM (
          SELECT s.hour::int
          FROM generate_series(0,23) AS s(hour)
        ) day_hours
        LEFT OUTER JOIN ( #{@page_views.to_sql} ) page_views
        ON day_hours.hour = EXTRACT(hour FROM page_views.created_at AT TIME ZONE 'UTC' AT TIME ZONE '#{Time.zone.tzinfo.canonical_identifier}')
        GROUP BY day_hours.hour
        ORDER BY day_hours.hour
      EOS
    )
  end

  # 0 - 23
  def page_views_by_hour
    {}.tap do |hours|
      temp = dataset_for_day_of_page_views

      (0..23).each do |index|
        hours[index.to_s] = temp[index]&.page_views_count
      end
    end
  end

  def max_page_views
    @dataset.map { |day_key, hours_hash| hours_hash.values.max }.max
  end

  def calc_databand_length
    # puts "max_page_views: #{max_page_views}"
    # puts "banding_divisor: #{banding_divisor}"

    # We're using 9 color bands in graph
    @band_length = max_page_views / 9.0
  end

  def class_for_databand(count_for_day)
    # puts "Day count: #{count_for_day} - Band length: #{@band_length}"

    case count_for_day
    when 0
      'band-0'
    when 1...@band_length
      'band-1'
    when (@band_length*1)...(@band_length*2)
      'band-2'
    when (@band_length*2)...(@band_length*3)
      'band-3'
    when (@band_length*3)...(@band_length*4)
      'band-4'
    when (@band_length*4)...(@band_length*5)
      'band-5'
    when (@band_length*5)...(@band_length*6)
      'band-6'
    when (@band_length*6)...(@band_length*7)
      'band-7'
    when (@band_length*7)...(@band_length*8)
      'band-8'
    when (@band_length*8)...Float::INFINITY
      'band-8'
    end
  end
end
