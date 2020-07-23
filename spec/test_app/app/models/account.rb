class Account < ActiveRecord::Base
  has_many :users
  has_many :pseudonyms

  def id
    1
  end

  def self.default
    Account.new
  end

  def account_users
    [AccountUser.new]
  end

  def self.account_admin
    account = ::Account.default.account_users.find do |account_user|
      account_user.role.name == 'AccountAdmin'
    end.try(:user)
  end
end