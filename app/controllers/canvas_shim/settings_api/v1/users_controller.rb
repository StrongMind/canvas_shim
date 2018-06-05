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
        end

        private

        def settings
          JSON.parse(params[:settings])
        end

        def validate_key
          token = AccessToken.authenticate(headers['Authorization'].gsub('Bearer ', ''))
          if token
            token.user.system_admin?
          else
            render status: 402, 'Bad token'
          end

        end
      end
    end
  end
end
