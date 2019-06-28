Rails.application.routes.draw do
  mount CanvasShim::Engine => "/canvas_shim"
end
