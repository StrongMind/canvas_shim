# Usage:
# SettingsService.update_enrollment_setting(id: 1, setting: 'foo', value: 'bar')
module SettingsService
  def self.update_enrollment_setting(id:, setting:, value:)
    Commands::UpdateEnrollmentSetting.new(
      id: id,
      setting: setting,
      value: value
    ).call
  end

  def self.get_enrollment_settings(id:)
    Commands::GetEnrollmentSettings.new(
      id: id
    ).call
  end
end
