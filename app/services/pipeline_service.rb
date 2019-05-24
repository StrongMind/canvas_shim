# The public api for the PipelineService
# By default the command will be enqueued.
#
# Example: PipelineService.publish(User.first)
module PipelineService
  def self.publish(object, options={})
    return if SettingsService.get_settings(object: :school, id: 1)['disable_pipeline']
    api.new(object, options).call
    self
  end

  def self.republish(options)
    API::Republish.new(options).call
    self
  end

  def self.api
    API::Publish
  end

  module V2
    def self.publish(model)
      begin
        V2::API::Publish.new(model).call
      rescue StandardError => exception
        Raven.captureException(exception)
      end
    end
  end
end
