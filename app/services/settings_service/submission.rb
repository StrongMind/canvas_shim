module SettingsService
  class Submission
    def self.table_name
      [SettingsService.settings_table_prefix, '-', 'submission_settings'].join('')
    end
    def self.put(id:, setting: , value:)
      Repository.put(
        table_name: table_name,
        id: id,
        setting: setting,
        value: value
      )
    end
    def table_name
      self.class.table_name
    end
    def self.create_table
      Repository.create_table(name: table_name)
    end
    def self.get(id:)
      Repository.get(table_name: table_name, id: id)
    end
  end
end
