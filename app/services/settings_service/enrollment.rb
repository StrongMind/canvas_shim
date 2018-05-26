module SettingsService
  class Enrollment
    TABLE_NAME = [ENV['CANVAS_DOMAIN'], '-', 'enrollment_settings'].join('')
    def create_table
      Repository.create_table(name: TABLE_NAME)
    end

    def put(id:, setting: , value:)
      Repository.put(table_name: TABLE_NAME, id: id, setting: setting, value: value)
    end

    def self.get(id:)
      Repository.get(table_name: TABLE_NAME, id: id)
    end
  end
end
