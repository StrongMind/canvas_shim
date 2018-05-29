module CanvasShim
  class Engine < ::Rails::Engine
    config.autoload_paths << File.expand_path("app/services", __dir__)
    isolate_namespace CanvasShim

    # config.paths.add File.join('app', 'api'), glob: File.join('**', '*.rb')
    # config.autoload_paths << File.expand_path("app/api", __dir__)

    config.generators do |g|
      g.test_framework :rspec
    end
  end
end
