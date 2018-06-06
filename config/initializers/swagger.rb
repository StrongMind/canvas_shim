class Swagger::Docs::Config
  def self.base_application; CanvasShim::Engine end

  def self.transform_path(path, api_version)
    # Make a distinction between the APIs and API documentation paths.
    "apidocs/#{path}"
  end

  Swagger::Docs::Config.register_apis({

    'v1' => {
        swagger: '2.0',
        controller_base_path: '',
        api_file_path: 'public/apidocs',
        base_path: 'http://localhost:3001',
        clean_directory: true,
        # parent_controller: CanvasShim::SettingsApi::V1::UsersController
    }
  })
end
