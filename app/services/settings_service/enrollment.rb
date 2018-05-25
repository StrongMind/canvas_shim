module SettingsService
  class Enrollment
    def create_table
      Repository.create_table(name: name)
    end

    def put(id:, setting: , value:)
      Repository.put(table_name: name, id: id, setting: setting, value: value)
    end

    def get(id:)
      Repository.get(table_name: name, id: id)
    end

    def name
      [
        ENV['CANVAS_DOMAIN'],
        '-',
        'enrollment_settings'
      ].join('')
    end
  end
end
