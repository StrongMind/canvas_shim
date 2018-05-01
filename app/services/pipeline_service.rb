# The public api for the PipelineService
# By default the command will be enqueued.
#
# Example: PipelineService.publish(User.first)
module PipelineService
  def self.publish(object, api: PipelineService::API::Publish)
    api.new(object).call
  end
end
