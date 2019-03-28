module SettingsService
  class GradeOverride
    def self.table_name
      [SettingsService.canvas_domain, '-', 'grade_override_settings'].join('')
    end
    def self.put(id:, setting: , value:)
      GradeOverrideRepository.put(
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
      GradeOverrideRepository.create_table(name: table_name)
    end
    def self.get(id:)
      GradeOverrideRepository.get(table_name: table_name, id: id)
    end
  end
end
