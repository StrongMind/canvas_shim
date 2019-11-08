module AssignmentsService
  def self.distribute_due_dates(args={})
    object = args.keys.first
    raise 'missing either course or enrollment' unless [:course, :enrollment].include?(object)

    case object
    when :course
      Commands::DistributeDueDates.new(course: args[:course]).call
    when :enrollment
      command = Commands::SetEnrollmentAssignmentDueDates.new(enrollment: args[:enrollment])
      Delayed::Job.enqueue(command)
    end
  end

  def self.distribute_dates_job(args={})
    command = Commands::DistributeDueDates.new(course: args[:course])
    Delayed::Job.enqueue(command)
  end

  def self.clear_due_dates(course:)
    command = Commands::ClearDueDates.new(course: course)
    Delayed::Job.enqueue(command)
  end

  def self.clear_due_dates!(course:)
    Commands::ClearDueDates.new(course: course).call
  end
end
