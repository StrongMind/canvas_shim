# Usage:
# SettingsService.update_enrollment_setting(id: 1, setting: 'foo', value: 'bar')
module SettingsService
  cattr_writer :canvas_domain

  def self.update_settings(id:, setting:, value:, object:)
    Commands::UpdateSettings.new(
      id: id,
      setting: setting,
      value: value,
      object: object
    ).call
  end

  def self.get_settings(id:, object:)
    Commands::GetSettings.new(id: id, object: object).call
  end

  def self.canvas_domain
    @@canvas_domain || ENV['CANVAS_DOMAIN']
  end

end
