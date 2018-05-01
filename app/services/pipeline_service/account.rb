module PipelineService
  module Account
    def self.account_admin
      account = ::Account.default.account_users.find do |account_user|
        account_user.role.name == 'AccountAdmin'
      end.try(:user)

      # return unless account
      # account.user
    end
  end
end
