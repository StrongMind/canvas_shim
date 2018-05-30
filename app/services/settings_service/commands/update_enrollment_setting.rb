module SettingsService
  module Commands
    class UpdateEnrollmentSetting
      def initialize id:, setting:, value:
        @id = id
        @setting = setting
        @value = value
      end

      def call
        SettingsService::Enrollment.create_table
        SettingsService::Enrollment.put(
          id: @id,
          setting: @setting,
          value: @value
        )
      end
    end
  end
end
