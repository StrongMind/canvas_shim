# The public api for the PipelineService
# By default the command will be enqueued.
#
# Example: PipelineService.publish(User.first)
module PipelineService
  def self.publish(object, api: PipelineService::API::Publish, noun: nil)
    api.new(object, noun: noun).call
  end
end
