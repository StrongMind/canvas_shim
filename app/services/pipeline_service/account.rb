module PipelineService
  module Account
    def self.account_admin
      ::Account.default.account_users.find do |account_user|
        account_user.role.name == 'AccountAdmin'
      end.user
    end
  end
end
