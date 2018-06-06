CanvasShim::Engine.routes.draw do
  namespace "settings_api" do
    namespace 'v1' do
      resources :users, only: ['update']
    end
  end

  get '/api' => redirect('/swagger/dist/index.html?url=/apidocs/api-docs.json')
end
