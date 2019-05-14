# The public api for the PipelineService
# By default the command will be enqueued.
#
# Example: PipelineService.publish(User.first)
module PipelineService
  cattr_reader :queue_mode

  def self.publish(object, api: API::Publish, noun: nil)
    return if SettingsService.get_settings(object: :school, id: 1)['disable_pipeline']

    api.new(object, noun: noun).call
    self
  end

  def self.republish(options)
    API::Republish.new(options).call
    self
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
