module SettingsService
  module Commands
    class UpdateSettings
      def initialize id:, setting:, value:, object:
        @id = id
        @setting = setting
        @value = value
        @object = object
      end

      def call
        object.create_table
        object.put(id: @id, setting: @setting, value: @value)
      end

      private

      def object
        SettingsService.const_get(@object.titleize)
      end
    end
  end
end
