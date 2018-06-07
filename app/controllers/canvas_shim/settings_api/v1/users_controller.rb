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

        def valid_token?(token)
          return false if token.nil?
          token.user.user_roles(Account.site_admin).include?('root_admin')
        end

        def validate_key
          token = SettingsService::AuthToken.authenticate(request.headers['HTTP_AUTHORIZATION'].try(:gsub, 'Bearer ', ''))
          render(json: {status: 'error'}, status: 401) and return unless token
          # return true #if valid_token?(token)
        end
      end
    end
  end
end
