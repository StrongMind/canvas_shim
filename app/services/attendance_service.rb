module AttendanceService
  def self.check_lockout(user: nil)
    Commands::CheckLockout.new(user: user).call
  end
end
