Delayed::Job.class_eval do
  before_save :truncate_source_column

  def truncate_source_column
    limit = Delayed::Job.columns_hash['source'].limit
    puts self.source if self.source.length > limit
    self.source = self.source[0..limit-1] if self.source.length > limit
  end

  def self.alert_long_running_jobs
    jobs = Delayed::Job.where('locked_at <= ?', 12.hours.ago)
    if jobs.any?
      Rails.logger.warn "[JOB QUEUE] #{jobs.count} delayed jobs running for more than 12 hours"
    end
  end
end
