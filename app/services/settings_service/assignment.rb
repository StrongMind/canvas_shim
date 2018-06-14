module SettingsService
  class Assignment
    cattr_writer :canvas_domain
    def self.table_name
      [SettingsService.canvas_domain, '-', 'assignment_settings'].join('')
    end
    def self.put(id:, setting: , value:)
      AssignmentRepository.put(
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
      AssignmentRepository.create_table(name: table_name)
    end
    def self.get(id:)
      AssignmentRepository.get(table_name: table_name, id: id)
    end
    def self.canvas_domain
      @@canvas_domain || ENV['CANVAS_DOMAIN']
    end
  end
end
