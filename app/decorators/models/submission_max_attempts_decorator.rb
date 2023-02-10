Submission.class_eval do
  after_save :send_max_attempts_callback

  def send_max_attempts_callback
    return unless student_locked?
    return unless send_max_attempts_alert?
    teachers_to_alert.each do |teacher|
      AlertsService::Client.create(
        :max_attempts_reached_min_score,
        teacher_id: teacher.id,
        student_id: user.id,
        assignment_id: assignment.id,
        course_id: assignment.course.id,
        score: score
      )
    end
  end


  def send_max_attempts_alert?
    lti_graded_attempts == max_attempts
  end

  def student_locked?
    return unless lti_graded_attempts && max_attempts
    return unless lti_graded_attempts >= max_attempts

    content_tag = ContentTag.find_by(content_id: assignment.id, content_type: 'Assignment')
    requirement = content_tag&.context_module&.completion_requirements.find { |req| req[:id] == content_tag&.id }
    return unless requirement && requirement[:min_score]
    return unless best_score.to_f < requirement[:min_score]
    score.to_f < requirement[:min_score]
  end

  def best_score
    best_score = score.to_f
    versions = self.versions
    versions.each do |version|
      return if version.yaml.nil?
      version_score = YAML.load(version.yaml).stringify_keys['score']
      return if version_score.nil?
      if version_score.to_f > best_score.to_f
        best_score = version_score
      end
    end
    best_score
  end

  def teachers_to_alert
    assignment.course.teacher_enrollments.map { |enrollment| enrollment.user }
  end

  def max_attempts
    migration_id = assignment.try(:migration_id)
    return unless migration_id

    assignment_settings = SettingsService.get_settings(id: migration_id.to_s, object: 'assignment')
    student_assignment_settings = SettingsService.get_settings(
      id: {
        assignment_id: assignment.id,
        student_id: user.id
      },
      object: 'student_assignment'
    )

    if assignment.title.downcase == 'final exam'
      1
    elsif assignment_settings and assignment_settings['max_attempts']
      assignment_settings['max_attempts'].to_i
    elsif student_assignment_settings and student_assignment_settings['max_attempts']
      student_assignment_settings['max_attempts'].to_i
    end
  end

  def lti_graded_attempts
    versions = self.try(:versions)
    return unless versions
    versions.select do |ver|
      yaml_ver = YAML.load(ver.yaml)
      yaml_ver['grader_id'] &&
      yaml_ver['grader_id'] < 0 &&
      yaml_ver['workflow_state'] == 'graded'
    end.size
  end
end
