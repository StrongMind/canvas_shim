# Usage:
# SettingsService.update_enrollment_setting(id: 1, setting: 'foo', value: 'bar')
module SettingsService
  cattr_writer :settings_table_prefix

  def self.update_settings(id:, setting:, value:, object:)
    Commands::UpdateSettings.new(
      id: id,
      setting: setting,
      value: value,
      object: object
    ).call
  end

  def self.update_enrollment_setting(id:, setting:, value:)
    Commands::UpdateEnrollmentSetting.new(
      id: id,
      setting: setting,
      value: value
    ).call
  end

  def self.get_enrollment_settings(id:)
    Commands::GetEnrollmentSettings.new(id: id).call
  end

  def self.get_settings(id:, object:)
    Commands::GetSettings.new(id: id, object: object).call
  end

  def self.update_user_setting(id:, setting:, value:)
    Commands::UpdateUserSetting.new(
      id: id,
      setting: setting,
      value: value
    ).call
  end

  def self.get_user_settings(id:)
    Commands::GetUserSettings.new(id: id).call
  end

  def self.settings_table_prefix
    @@settings_table_prefix || ENV['SETTINGS_TABLE_PREFIX']
  end

  def self.query
    Queries::ZeroGraderAudit.run
  end

end
