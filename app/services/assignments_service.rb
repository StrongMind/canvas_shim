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

  def self.claim_import(course:)
    SettingsService.update_settings(
      object: 'course',
      id: course&.id,
      setting: 'imported_content',
      value: true
    )
  end
end
