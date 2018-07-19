module SettingsService
  class School
    OBJECT_NAME = 'school_settings'

    def self.create_table
      Repository.create_table(name: table_name)
    end

    def self.get(id:)
      Repository.get(table_name: table_name, id: id)
    end

    def self.table_name
      [SettingsService.canvas_domain, '-', OBJECT_NAME].join('')
    end
  end
end
