# The public api for the PipelineService
# By default the command will be enqueued.
#
# Set PIPELINE_SKIP_QUEUE=true to run command inline
#
# Example: PipelineService.publish(User.first)
module PipelineService
  def self.publish(object)
    # if ENV['PIPELINE_SKIP_QUEUE']
    #   job(object).perform
    # else
    #   Delayed::Job.enqueue job(object)
    # end
  end

  def self.job(object)
    Jobs::PostEnrollmentJob.new(
      command: PipelineService::Commands::Send.new(object: object)
    )
  end
end
