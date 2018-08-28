module GradesService
  def self.zero_out_grades!(force: false)
    if force == false
      return unless SettingsService.get_settings(object: :school, id: 1)['zero_out_past_due'] == 'on'
    end

    ::Assignment
      .left_outer_joins(:submissions)
      .where.not(due_at: nil)
      .where('due_at < ?', 1.hour.ago)
      .where('submissions.score in (?)', [nil, 0])
      .distinct
      .in_batches(of: 1000) do |assignments|
        assignments.each do |assignment|
          GradesService::Commands::ZeroOutAssignmentGrades.new(assignment).call!
        end
        sleep 60
      end
  end
end
