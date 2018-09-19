module GradesService
  def self.zero_out_grades!(force: false)
    if force == false
      return unless SettingsService.get_settings(object: :school, id: 1)['zero_out_past_due'] == 'on'
    end

    scope.map(&:id).uniq.each do |id|
      Commands::ZeroOutAssignmentGrades.new(id).call!
    end
  end

  def self.scope
    ::Assignment
      .distinct
      .left_outer_joins(:submissions)
      .where.not(due_at: nil)
      .where('due_at < ?', 1.hour.ago)
      .where('submissions.score IS NULL')
      .select(:id)
  end
end
