# The public api for the PipelineService
module PipelineService
  def self.publish(object)
    PipelineService::Commands::Send.new(
      object: object
    ).call
  end
end
