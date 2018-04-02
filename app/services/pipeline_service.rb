# The public api for the PipelineService
module PipelineService
  def self.publish(enrollment)
    PipelineService::Commands::Send.new(
      enrollment: enrollment,
      user:       PipelineService::Account.account_admin
    ).call
  end
end
