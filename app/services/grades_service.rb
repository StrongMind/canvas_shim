module GradesService
  def self.zero_out_grades!(force: false, seconds_to_sleep: 1, batch_size: 50)
    if force == false
      return unless SettingsService.get_settings(object: :school, id: 1)['zero_out_past_due'] == 'on'
    end

    scope.in_batches(of: batch_size) do |batch|
      batch.each do |assignment|
        Commands::ZeroOutAssignmentGrades.new(assignment).call!
      end
      sleep seconds_to_sleep
    end
  end

  def self.scope
    ::Assignment
      .distinct
      .left_outer_joins(:submissions)
      .where.not(due_at: nil)
      .where('due_at < ?', 1.hour.ago)
      .where('submissions.score IS NULL')
  end
end
