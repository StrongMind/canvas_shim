require 'grape-swagger'

module SettingsService
  class RestAPI < Grape::API
    Grape::Middleware::Auth::Strategies.add(:auth_by_token, AuthMiddleware, ->(options) { [options[:realm]] })
    format :json
    default_format :json
    version 'v1'

    auth :auth_by_token, { realm: 'Settings Service API'} do |credentials|
      byebug
      #   # lookup the user's password here
      #   # AccessToken.authenticate(token_string, token_key = :crypted_token)
      #   # { 'user1' => 'password1' }[username]
    end

    resource :enrollments do
      route_param :id do
        desc 'Get settings associated with a user'
        get do
          puts "This is executable!"
          {type: 'enrollments', setting2: 'yes'}
        end

        desc 'Add settings to users'
        put do
          {}
        end
      end
    end

    resource :users do
      route_param :id do
        get do
          puts "This is executable!"
          {type: 'users', setting2: 'no'}
        end

        params do
          optional :json, type: JSON
        end

        post do
          SettingsService.update_user_setting(
            id: params[:id],
            setting: params[:json].keys.first,
            value: params[:json].values.first
          )
          params
        end
      end
    end
    add_swagger_documentation
  end
end
