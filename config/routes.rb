CanvasShim::Engine.routes.draw do
  namespace "settings_api" do
    resource :swagger, controller: 'swagger'
    get '/docs' => redirect('/swagger/dist/index.html?url=/canvas_shim/settings_api/swagger')
    namespace 'v1' do
      resources :users, only: ['update']
    end
  end
end
