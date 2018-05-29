module SettingsService
  module Commands
    class UpdateEnrollmentSetting
      def initialize id:, setting:, value:
        @id = id
        @setting = setting
        @value = value
      end

      def call
        enrollment = SettingsService::Enrollment.new
        enrollment.put(
          id: @id,
          setting: @setting,
          value: @value
        )
      end
    end
  end
end
