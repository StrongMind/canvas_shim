module SettingsService
  class Assignment
    def self.table_name
      [SettingsService.settings_table_prefix, '-', 'assignment_settings'].join('')
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
  end
end
