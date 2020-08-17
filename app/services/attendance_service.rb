module AttendanceService
  def self.check_lockout(pseudonym: nil)
    Commands::CheckLockout.new(pseudonym: pseudonym).call
  end
end
