module SettingsService
  class AuthToken
    cattr_writer :authenticator

    # Set SettingsService::AuthToken.authenticator to override
    # in the LMS
    def self.authenticator
      @@authenticator || AuthenticatorStub
    end

    def self.authenticate(key)
      authenticator.authenticate(key)
    end
  end
end
