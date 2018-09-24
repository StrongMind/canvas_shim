module GradesService
  def self.zero_out_grades!(options={})

    if options[:force] == false
      return unless SettingsService.get_settings(object: :school, id: 1)['zero_out_past_due'] == 'on'
    end

    Submission.find_each do |submission|
      Commands::ZeroOutAssignmentGrades.new(submission).call!(options)
    end
  end
end
