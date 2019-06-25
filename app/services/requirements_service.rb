module RequirementsService
  def self.apply_minimum_scores(context_module:, force: false)
    Commands::ApplyMinimumScores.new(context_module: context_module, force: force).call
  end
end