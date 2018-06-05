CanvasShim::Engine.routes.draw do
  mount GrapeSwaggerRails::Engine => 'api/docs'
  mount SettingsService::RestAPI => 'settings_api'
end
