module SettingsService
  class Login
    OBJECT_NAME = 'login_settings'

    def self.create_table
      Repository.create_table(name: table_name)
    end

    def self.get(id:)
      Repository.get(table_name: table_name, id: id)
    end

    def self.put(id:, setting: , value:)
      Repository.put(
        table_name: table_name,
        id: id,
        setting: setting,
        value: value
      )
    end

    def self.table_name
      [SettingsService.settings_table_prefix, '-', OBJECT_NAME].join('')
    end
  end
end
