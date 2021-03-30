module SpecialProgramsService
  def self.get_programs(user:)
    Commands::GetPrograms.new(user: user).call
  end
end