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
    send_later(command, args[:course])
  end

  def self.clear_due_dates(course:)
    command = Commands::ClearDueDates.new(course: course)
    send_later(command, course)
  end

  def self.clear_due_dates!(course:)
    Commands::ClearDueDates.new(course: course).call
  end

  def self.handle_overrides(assignment:, due_at:)
    Commands::HandleOverrides.new(assignment: assignment, due_at: due_at).call
  end

  def self.is_distributing?(course)
    Delayed::Job.current.exists?(strand: "course_due_dates:#{course.try(:id)}")
  end

  def self.send_later(command, course)
    command.send_later_enqueue_args(
      :perform, { strand: "course_due_dates:#{course.try(:id)}" }
    )
  end
end
