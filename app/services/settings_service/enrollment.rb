module SettingsService
  class Enrollment

    def create_table
      Repository.create_table(name: table_name)
    end

    def put(id:, setting: , value:)
      Repository.put(table_name: table_name, id: id, setting: setting, value: value)
    end

    def self.get(id:)
      Repository.get(table_name: table_name, id: id)
    end

    def self.table_name
      [ENV['CANVAS_DOMAIN'], '-', 'enrollment_settings'].join('')
    end

    def table_name
      self.class.table_name
    end
  end
end
