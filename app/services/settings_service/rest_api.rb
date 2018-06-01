require 'grape-swagger'
module SettingsService
  class RestAPI < Grape::API
    format :json
    version 'v1'

    resource :enrollments do
      route_param :id do
        desc 'Get settings associated with a user'
        get do
          {type: 'enrollments', setting2: 'yes'}
        end

        desc 'Add settings to users'
        put do
          { }
        end
      end
    end

    resource :users do
      route_param :id do
        get do
          {type: 'users', setting2: 'no'}
        end

        put do
          { }
        end
      end
    end
    add_swagger_documentation
  end
end
