Rails.application.routes.draw do
  mount CanvasShim::Engine => "/canvas_shim"
  resources :courses
end
