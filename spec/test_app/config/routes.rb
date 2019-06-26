Rails.application.routes.draw do
  mount CanvasShim::Engine => "/canvas_shim"
  
  resources :courses do
    resources :assignments do
      resources :submission
    end
  end  
end