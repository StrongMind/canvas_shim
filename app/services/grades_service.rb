module GradesService
  def self.zero_out_grades!(force: false)
    if force == false
      return unless SettingsService.get_settings(object: :school, id: 1)['zero_out_past_due'] == 'on'
    end

    # Question: Do we get assignments with no submissions?
    ::Assignment
      .left_outer_joins(:submissions)
      .where.not(due_at: nil)
      .where('due_at < ?', 1.hour.ago)
      .where('submissions.score = ?', nil)
      .distinct
      .in_batches do |assignments|
        assignments.each do |assignment|
          GradesService::Commands::ZeroOutAssignmentGrades.new(assignment).call!
        end
        sleep 60
      end
  end
end
