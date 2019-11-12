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

  def self.toggle_distribution_state(course, state)
    SettingsService.update_settings(
      object: 'course',
      id: course.try(:id),
      setting: 'distribution_state',
      value: state
    )
  end

  def self.dist_on(course)
    toggle_distribution_state(course, true)
  end

  def self.dist_off(course)
    toggle_distribution_state(course, false)
  end

  def self.get_distribution_state(course)
    SettingsService.get_settings(object: :course, id: course.try(:id))['distribution_state']
  end
end
