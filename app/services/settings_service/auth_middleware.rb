module SettingsService
  class AuthMiddleware
    def initialize app, arg2
      @arg2 = arg2
      @app = app
    end

    def call env
      key = env['HTTP_AUTHORIZATION']
      key = key.delete('Bearer ') if key

      @app.call(env) if AuthToken.authenticate(key)
    end
  end
end
