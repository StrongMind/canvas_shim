module GradesService
  module Account
    def self.account_admin
      account = ::Account.default.account_users.find do |account_user|
        account_user.role.name == 'AccountAdmin'
      end.try(:user)
    end

    def self.strongmind_grader
      User.new(id: -1001)
    end
  end
end
