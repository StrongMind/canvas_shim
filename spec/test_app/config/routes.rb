Rails.application.routes.draw do
  mount CanvasShim::Engine => "/canvas_shim"
  
  resources :courses do
    get 'settings' => 'courses#settings'
  end
end
