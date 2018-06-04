require 'grape-swagger'

module SettingsService
  class RestAPI < Grape::API
    Grape::Middleware::Auth::Strategies.add(:auth_by_token, AuthMiddleware, ->(options) { [options[:realm]] })
    format :json
    version 'v1'

    auth :auth_by_token, { realm: 'Settings Service API'} do |credentials|
    #   byebug
    #   # lookup the user's password here
    #   # AccessToken.authenticate(token_string, token_key = :crypted_token)
    #   # { 'user1' => 'password1' }[username]
    end

    resource :enrollments do
      route_param :id do
        desc 'Get settings associated with a user'
        get do
          {type: 'enrollments', setting2: 'yes'}
        end

        desc 'Add settings to users'
        put do
          update_enrollment_setting(
            id: params[:enrollment_id],
            setting: params[:id],
            value: params[:value]
          )
        end
      end
    end

    resource :users do
      route_param :id do
        get do
          { type: 'users', setting2: 'no' }
        end

        put do
          { }
        end
      end
    end
    add_swagger_documentation
  end
end
