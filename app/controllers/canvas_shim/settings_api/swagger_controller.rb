module CanvasShim
  module SettingsApi
    class SwaggerController < ApplicationController
      def show
        render json: YAML.load_file(
          Engine.root.to_s + "/app/services/settings_service/api_docs.yml"
        ).to_json
      end
    end
  end
end
