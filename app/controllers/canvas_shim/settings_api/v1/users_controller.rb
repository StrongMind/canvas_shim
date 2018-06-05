module CanvasShim
  module SettingsApi
    module V1
      class UsersController < ApplicationController
        skip_before_action :verify_authenticity_token
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
      end
    end
  end
end
