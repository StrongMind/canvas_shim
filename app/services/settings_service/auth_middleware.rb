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
        [500, {"Content-Type" => "application/json"}, ['{ "message" : "Bad Auth Token!" }']]
      end
    end
  end
end
