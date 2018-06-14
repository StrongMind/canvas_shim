
module SettingsService
  module Commands
    # DEPRICATED: Use "GetSettings instead"
    class GetUserSettings
      def initialize id:
        @id = id
      end

      def call
        SettingsService::User.create_table
        SettingsService::User.get(
          id: @id
        )
      end
    end
  end
end
