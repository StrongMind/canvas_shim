module SettingsService
  module Commands
    class GetSettings
      def initialize(id:, object:)
        @id = id
        @object = object
      end

      def call
        object.create_table
        object.get(id: @id)
      end

      private

      def object
        SettingsService.const_get(@object.titleize)
      end
    end
  end
end
