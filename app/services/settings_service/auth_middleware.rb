module SettingsService
  class AuthMiddleware
    def initialize app, arg2
      @arg2 = arg2
      @app = app
    end

    def call env
      key = env['HTTP_AUTHORIZATION']
      key = key.delete('Bearer ') if key

      if AuthToken.authenticate(key)
        @app.call(env)
      else
        [401, {"Content-Type" => "application/json"}, ['{ "message" : "Unauthorized" }']]
      end
    end
  end
end
