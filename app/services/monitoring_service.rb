module MonitoringService
  def self.alert_long_running_jobs
    jobs = Delayed::Job.where('locked_at <= ?', 12.hours.ago)
    if jobs.any?
      Rails.logger.warn "[JOB QUEUE] #{jobs.count} delayed #{"job".pluralize(jobs.count)} running for more than 12 hours"
    end
  end
end