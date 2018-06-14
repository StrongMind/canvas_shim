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
        case @object
        when 'assignment'
          SettingsService::Assignment
        when 'user'
          SettingsService::User
        when 'enrollment'
          SettingsService::Enrollment
        end
      end
    end
  end
end
