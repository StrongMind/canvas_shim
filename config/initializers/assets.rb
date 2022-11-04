Rails.application.config.assets.enabled = true
Rails.application.config.assets.precompile += %w(canvas_shim/application.js canvas_shim/application.css)
Rails.application.config.assets.paths << CanvasShim::Engine.root.join('node_modules')
