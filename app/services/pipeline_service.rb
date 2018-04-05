# The public api for the PipelineService
module PipelineService
  def self.publish(object)
    job = Jobs::PostEnrollmentJob.new(
      command: PipelineService::Commands::Send.new(object: object)
    )

    if ENV['PIPELINE_SKIP_QUEUE']
      job.perform
    else
      Delayed::Job.enqueue job
    end
  end
end
