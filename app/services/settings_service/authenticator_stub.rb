# This won't be used in production.  Set AuthToken.authenticator = ::AccessToken
# a CanvasLMS initializer
module SettingsService
  class AuthenticatorStub
    def self.authenticate(key)
      true
    end
  end
end
