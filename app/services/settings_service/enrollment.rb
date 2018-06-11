module SettingsService
  class Enrollment
    cattr_writer :canvas_domain

    def self.create_table
      Repository.create_table(name: table_name)
    end

    def self.put(id:, setting: , value:)
      Repository.put(
        table_name: table_name,
        id: id,
        setting: setting,
        value: value
      )
    end

    def self.get(id:)
      Repository.get(table_name: table_name, id: id)
    end

    def self.table_name
      [self.canvas_domain, '-', 'enrollment_settings'].join('')
    end

    def table_name
      self.class.table_name
    end

    def self.canvas_domain
      @@canvas_domain || ENV['CANVAS_DOMAIN']
    end
  end
end
