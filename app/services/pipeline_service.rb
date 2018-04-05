# The public api for the PipelineService
module PipelineService
  def self.publish(object)

    def build_job
      @job = Jobs::PostEnrollmentJob.new(
        command: PipelineService::Commands::Send.new(
          object: object
        )
      )
    end
  end
end
