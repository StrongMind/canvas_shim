require 'grape-swagger'

module SettingsService
  class RestAPI < Grape::API
    Grape::Middleware::Auth::Strategies.add(:auth_by_token, AuthMiddleware, ->(options) { [options[:realm]] })
    format :json
    default_format :json
    version 'v1'

    auth :auth_by_token, { realm: 'Settings Service API' } do |credentials|
    end

    resource :users do
      route_param :id do
        params do
          optional :settings, type: JSON
        end
        desc 'Adds a setting to a user' do
          detail 'send an id and a setting as json {"foo": "bar"}'
          failure [[401, '{"message": "unauthorized"}']]
        end
        post do
          params[:settings].each do |key, value|
            SettingsService.update_user_setting(
              id: params[:id],
              setting: key,
              value: value
            )
          end
          status 202
        end
      end
    end
    add_swagger_documentation
  end
end
