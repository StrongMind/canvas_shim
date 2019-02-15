# The public api for the PipelineService
# By default the command will be enqueued.
#
# Example: PipelineService.publish(User.first)
module PipelineService
  cattr_reader :queue_mode
  def self.publish(object, api: API::Publish)
    return if SettingsService.get_settings(object: :school, id: 1)['disable_pipeline']
    api.new(object).call
  end

  def self.perform_synchronously?
    queue_mode == 'synchronous'
  end

  @@queue_mode = ENV['SYNCHRONOUS_PIPELINE_JOBS'] == 'true' ? 'synchronous' : 'asynchronous'
  def self.queue_mode=(mode)
    case mode
    when 'synchronous'
      @@queue_mode = 'synchronous'
    when 'asynchronous'
      @@queue_mode = 'asynchronous'
    else
      raise 'unknown queue mode: ' + mode
    end
  end
end
