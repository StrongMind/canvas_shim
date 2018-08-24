module GradesService
  def self.zero_out_grades!
    return unless SettingsService.get_settings(object: :school, id: 1)['zero_out_past_due'] == 'on'
    ::Assignment.find_each do |assignment|
      Commands::ZeroOutAssignmentGrades.new(assignment).call!
    end
  end
end
