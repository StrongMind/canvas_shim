module RequirementsService
  def self.apply_minimum_scores_to_unit(context_module:, force: false)
    Commands::ApplyMinimumScoresToUnit.new(context_module: context_module, force: force).call
  end
end