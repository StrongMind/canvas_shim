Submission.class_eval do
  after_commit :send_max_attempts_alert

  def send_max_attempts_alert
    return unless used_attempts && max_attempts
    if used_attempts >= max_attempts
      #send an alert
    end
  end

  def max_attempts
    max_attempts = 0
    assignment = self.assignment
    user = self.user
    migration_id = self.assignment.try(:migration_id)
    return unless migration_id

    assignment_settings = SettingsService.get_settings(id: migration_id.to_s, object: 'assignment')
    student_assignment_settings = SettingsService.get_settings(
        id: {
          assignment_id: assignment.id,
          student_id: user.id
        },
        object: 'student_assignment')

    ### Temporary Ugly Hack ##
    if assignment.title.downcase == 'final exam'
      max_attempts = 1
    end

    if assignment_settings and assignment_settings['max_attempts']
      max_attempts = assignment_settings['max_attempts'].to_i
    end

    if student_assignment_settings and student_assignment_settings['max_attempts']
      max_attempts = student_assignment_settings['max_attempts'].to_i
    end
    max_attempts
  end

  def used_attempts
    versions =  self.try(:versions)
    return unless versions
    versions.map.select { |ver| YAML.load(ver.yaml)['grader_id'] && YAML.load(ver.yaml)['grader_id'] < 0 }.map {|ver| YAML.load(ver.yaml)['attempt'] || 0}.uniq.sort.last
  end
end
