module MonitoringService
  def self.alert_long_running_jobs
    jobs = Delayed::Job.where('locked_at <= ?', 12.hours.ago)
    if jobs.any?
      Rails.logger.warn "[JOB QUEUE] #{jobs.count} delayed #{"job".pluralize(jobs.count)} running for more than 12 hours. Original Job IDs: #{jobs.pluck(:id)}"
      MonitoringService.requeue_long_running_jobs(jobs)
    end
  end

  def self.requeue_long_running_jobs(jobs)
    jobs.each do |job|
      job.update!(run_at: 15.minutes.from_now, locked_by: nil, locked_at: nil, attempts: 0)
    end
  end
end