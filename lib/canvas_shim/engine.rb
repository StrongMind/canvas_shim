require 'byebug'
module CanvasShim
  class Engine < ::Rails::Engine
    config.autoload_paths << File.expand_path("app/services", __dir__)
    isolate_namespace CanvasShim

    config.paths.add File.join('app', 'api'), glob: File.join('**', '*.rb')
    config.autoload_paths << File.expand_path("app/api", __dir__)

    #byebug
    #config.autoload_paths += Dir[Rails.root.join('app', 'api', '*')]

    config.generators do |g|
      g.test_framework :rspec
    end
    config.assets.precompile += %w(swagger_ui.js swagger_ui.css swagger_ui_print.css swagger_ui_screen.css)

  end
end
