module SettingsService
  class AuthToken
    cattr_writer :authenticator

    # Set SettingsService::AuthToken.authenticator to override
    # in the LMS
    def self.authenticator
      @@authenticator || AuthenticatorStub
    end

    def self.authenticate(key)
      return valid_token?(authenticator.authenticate(key))
    end

    def self.valid_token?(token)
      return false if token.nil?
      token.user.user_roles(Account.site_admin).include?('root_admin')
    end

  end
end
