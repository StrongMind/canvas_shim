# GrapeSwaggerRails.options.url      = '/swagger_doc.json'
GrapeSwaggerRails.options.url = '/canvas_shim/settings_api/v1/swagger_doc'
GrapeSwaggerRails.options.app_name = 'SettingsService'
GrapeSwaggerRails.options.before_action do
  GrapeSwaggerRails.options.app_url = request.protocol + request.host_with_port
end
