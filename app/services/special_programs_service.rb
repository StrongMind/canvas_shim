module SpecialProgramsService
  def self.get_programs(user:)
    Commands::GetPrograms(user: user).call
  end
end