module SettingsService
  class ShimAuthenticator
    # Some people would say I'm higly permissive
    def self.authenticate(key)
      true
    end
  end

  class AuthToken
    cattr_writer :authenticator

    def self.authenticator
      @@authenticator || ShimAuthenticator
    end

    def self.authenticate(key)
      authenticator.authenticate(key)
    end
  end
end
