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
    send_later(command)
  end

  def self.clear_due_dates(course:)
    command = Commands::ClearDueDates.new(course: course)
    send_later(command)
  end

  def self.clear_due_dates!(course:)
    Commands::ClearDueDates.new(course: course).call
  end

  def self.is_distributing?(course)
    Delayed::Job.current.exists?(strand: "course_due_dates:#{course.try(:id)}")
  end

  def self.send_later(command)
    command.send_later_if_production_enqueue_args(
      :perform,
      { strand: "course_due_dates:#{course.try(:id)}" },
      { course: course }
    )
  end
end
