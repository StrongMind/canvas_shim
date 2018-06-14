module CanvasShim
  class ApplicationController < ActionController::Base
    protect_from_forgery with: :exception

    def validate_key
      token = SettingsService::AuthToken.authenticate(
        request.headers['HTTP_AUTHORIZATION'].try(:gsub, 'Bearer ', '')
      )
      render(json: {status: 'error'}, status: 401) and return unless token
    end
  end
end
