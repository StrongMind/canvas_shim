Delayed::WorkQueue::ParentProcess::Server.class_eval do

  alias_method :original_check_for_work, :check_for_work

  def check_for_work
    # set logger into debug mode to trigger logging number
    # of jobs in queue and idle workers
    original_log_level = Rails.logger.level
    Rails.logger.level = Logger::DEBUG
    original_check_for_work
    Rails.logger.level = original_log_level
  end
end
