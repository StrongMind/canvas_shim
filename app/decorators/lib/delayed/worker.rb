require 'concurrent/scheduled_task'

Delayed::Worker.class_eval do
  @@mutex = Mutex.new
  @@active_jobs = 0
  @@task_protection_state = false
  @@deactivation_pending = false
  @@deactivation_task = nil

  alias_method :original_perform, :perform

  def perform(job)
    @@mutex.synchronize do
      @@active_jobs += 1
      Rails.logger.info("Pre Perform Active jobs for worker #{name}: #{@@active_jobs}")
      set_task_protection(true) if @@active_jobs == 1
    end
    count = original_perform(job)
    @@mutex.synchronize do
      @@active_jobs -= 1
      Rails.logger.info("Post Perform Active jobs for worker #{name}: #{@@active_jobs}")
      set_task_protection(false) if @@active_jobs == 0
    end
    count
  end

  def set_task_protection(state)
    return unless ENV['ECS_AGENT_URI']
    return unless state != @@task_protection_state
    begin
      if state
        cancel_deactivation_task
        send_task_protection_to_ecs(true)
      else
        debounced_task_protection_deactivation
      end

      @@task_protection_state = state

    rescue StandardError => e
      raise "An error occurred: #{e.message}"
    end
  end

  def debounced_task_protection_deactivation
    return if @@deactivation_pending
    @@deactivation_pending = true
    @@deactivation_task = Concurrent::ScheduledTask.execute(60) do
      @@mutex.synchronize do
        if @@active_jobs == 0
          send_task_protection_to_ecs(false)
        end
        @@deactivation_pending = false
      end
    end
  end

  def cancel_deactivation_task
    return unless @@deactivation_task
    @@deactivation_task.cancel
    @@deactivation_pending = false
  end

  def send_task_protection_to_ecs(state)
    ecs_agent_uri = ENV['ECS_AGENT_URI']
    state_endpoint = "#{ecs_agent_uri}/task-protection/v1/state"
    uri = URI.parse(state_endpoint)
    request = Net::HTTP::Put.new(uri)
    request['Content-Type'] = 'application/json'
    request.body = { 'ProtectionEnabled' => state }.to_json

    response = Net::HTTP.start(uri.hostname, uri.port) do |http|
      http.request(request)
    end

    unless response.is_a?(Net::HTTPSuccess)
      raise "Failed to update ECS task protection state: #{response.body}"
    end
  end

end
