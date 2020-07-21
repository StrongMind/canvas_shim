module SettingsService
  class School
  OBJECT_NAME = 'school_settings'

    def self.create_table
      Repository.create_table(name: table_name)
    end

    def self.get(id:)
      school_settings = Rails.cache.read(self.table_name)
      unless school_settings
        school_settings = Repository.get(table_name: table_name, id: id)
        Rails.cache.write(self.table_name, school_settings, expires_in: 5.minutes)
      end
      school_settings
    end

    def self.put(id:, setting: , value:)
      res = Repository.put(
        table_name: table_name,
        id: id,
        setting: setting,
        value: value
      )
      school_settings = Repository.get(table_name: table_name, id: id)
      Rails.cache.write(self.table_name, school_settings, expires_in: 5.minutes)
      res
    end

    def self.table_name
      [SettingsService.settings_table_prefix, '-', OBJECT_NAME].join('')
    end
  end
end
