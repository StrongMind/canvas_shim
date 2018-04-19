# The public api for the PipelineService
# By default the command will be enqueued.
#
# Set PIPELINE_SKIP_QUEUE=true to run command inline
#
# Example: PipelineService.publish(User.first)
module PipelineService
  def self.publish(object, api: PipelineService::API::Publish)
    # raise 'here be an error'
    api.new(object).call
  end
end
