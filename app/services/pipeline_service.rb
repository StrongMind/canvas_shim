# The public api for the PipelineService
module PipelineService
  def self.publish(object)
    Jobs::PostEnrollmentJob.new(
      command: PipelineService::Commands::Send.new(object: object)
    ).perform
  end
end
