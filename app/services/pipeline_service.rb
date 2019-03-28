# The public api for the PipelineService
# By default the command will be enqueued.
#
# Example: PipelineService.publish(User.first)
module PipelineService
  cattr_reader :queue_mode
  def self.publish(object, api: API::Publish, noun: nil)
    return if SettingsService.get_settings(object: :school, id: 1)['disable_pipeline']
    api.new(object, noun: noun).call
  end

  def self.republish(start_at, end_at)
    API::Republish.new(start_at, end_at)
  end
end
