# The public api for the PipelineService
# By default the command will be enqueued.
#
# Set PIPELINE_SKIP_QUEUE=true to run command inline
#
# Example: PipelineService.publish(User.first)
module PipelineService
  def self.publish(object)
    return command(object).call if ENV['PIPELINE_SKIP_QUEUE']
    Delayed::Job.enqueue Jobs::PostEnrollmentJob.new(command: command(object))
  end

  def self.command(object)
    PipelineService::Commands::Send.new(object: object)
  end
end
