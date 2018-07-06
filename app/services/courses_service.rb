module CoursesService
  def self.distribute_due_dates(course:)
    Commands::DistributeDueDates.new(course).call
  end
end
