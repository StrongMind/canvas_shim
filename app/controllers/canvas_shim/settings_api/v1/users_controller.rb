require 'swagger/docs'
module CanvasShim
  module SettingsApi
    module V1
      class UsersController < ApplicationController
        swagger_controller :users, 'Users'
        swagger_api :update do
          param   :body, :settings, :settings, :required, "A hash of settings"
          summary 'Updates a user setting'
          notes   'Format: {"yoursetting": "setting_value"}'
        end

        skip_before_action :verify_authenticity_token
        before_action :validate_key

        def update
          settings.each do |key, value|
            SettingsService.update_user_setting(
              id: params[:id],
              setting: key,
              value: value
            )
            render json: { status: 'ok' }
          end
        end

        private

        def settings
          params[:user]
        end

        def valid_token?(token)
          return false if token.nil?
          token.user.user_roles(Account.site_admin).include?('root_admin')
        end

        def validate_key
          return true
          token = AccessToken.authenticate(request.headers['HTTP_AUTHORIZATION'].try(:gsub, 'Bearer ', ''))

          return true if valid_token?(token)
          render(json: {status: 'error'}, status: 401)
        end
      end
    end
  end
end
