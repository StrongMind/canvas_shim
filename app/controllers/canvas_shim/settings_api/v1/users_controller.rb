module CanvasShim
  module SettingsApi
    module V1
      class UsersController < ApplicationController
        skip_before_action :verify_authenticity_token
        before_action :validate_key

        def update
          settings.each do |key, value|
            SettingsService.update_user_setting(
              id: params[:id],
              setting: key,
              value: value
            )
          end
          render json: { status: 'ok' }
        end

        private

        def settings
          params[:user]
        end

        def validate_key
          token = SettingsService::AuthToken.authenticate(
            request.headers['HTTP_AUTHORIZATION'].try(:gsub, 'Bearer ', '')
          )
          render(json: {status: 'error'}, status: 401) and return unless token
        end
      end
    end
  end
end
