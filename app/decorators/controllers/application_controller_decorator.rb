ApplicationController.class_eval do
  prepend_view_path CanvasShim::Engine.root.join('app', 'views')
end