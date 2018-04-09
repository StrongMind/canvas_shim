# The public api for the PipelineService
# By default the command will be enqueued.
#
# Set PIPELINE_SKIP_QUEUE=true to run command inline
#
# Example: PipelineService.publish(User.first)
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
