module PipelineService
  def self.publish(enrollment)
    PipelineService::Commands::Send.new(
      enrollment: enrollment,
      user: Account.default.account_users.find do |account_user|
              account_user.role.name == 'AccountAdmin'
            end.user
    ).call
  end
end
