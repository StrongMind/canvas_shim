require 'grape-swagger'
module CanvasShim
  class API < Grape::API

    format :json
    version 'v1'

    get 'hello' do
      {hello: 'world'}
    end

    resource :enrollments do
      route_param :id do
        resource :settings do
          get do
            { foo: 'bar' }
          end

          put do
          end
        end
      end
    end
    add_swagger_documentation(
      
      # :add_version => true

    )
  end
end
