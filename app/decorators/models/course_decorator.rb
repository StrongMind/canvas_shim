Course.class_eval do
  has_many :active_students, -> { where("enrollments.workflow_state NOT IN ('rejected', 'deleted', 'inactive', 'invited') AND enrollments.type = 'StudentEnrollment'").preload(:user) }, class_name: 'Enrollment'

  after_commit -> { PipelineService.publish(self) }
  after_create -> { RequirementsService.set_school_thresholds_on_course(course: self) }

  def force_min_scores
    context_modules.each do |cm|
      RequirementsService.apply_minimum_scores(context_module: cm, force: true)
    end
  end

  def no_active_students?
    active_students.count.zero?
  end

  def average_score
    course_scores = active_students.map do |active|
      active.scores.first.try(:current_score).to_f
    end

    course_scores.reduce(&:+).to_f / working_denominator(course_scores)
  end

  def average_completion_percentage
    avgs = active_students.map do |student|
      calculate_progress(student)
    end.reduce(&:+).to_f / working_denominator(active_students)
  end

  def needs_grading_count
    assignments.map(&:needs_grading_count).reduce(&:+).to_i
  end

  def get_relevant_alerts_count(user)
    return unless user
    AlertsService::Client.course_teacher_alerts(
      course_id: id,
      teacher_id: user.id,
    ).payload.size
  end

  def caag_student_details
    return if no_active_students?
    active_students.map do |student|
      {
        user: student.user,
        last_active: student.days_since_active,
        last_submission: student.days_since_last_submission,
        missing_assignments: student.missing_assignments_count,
        current_score: student.current_score,
        course_progress: "#{calculate_progress(student).round(1)}%",
        requirements_completed: student.string_progress,
        alerts: get_relevant_student_alerts_count(student.user)
      }
    end
  end

  def get_accesses_by_hour
    start_at = 6.days.ago.in_time_zone(time_zone_name).beginning_of_day
    query = "url NOT ILIKE ? AND user_id IN (?) AND created_at >= ?"
    as_ids = active_students.pluck(:user_id)
    api_match = "%/api/%"

    accesses = page_views.where(
      "#{query} OR #{query} AND updated_at >= ?",
      api_match, as_ids,
      start_at, api_match, as_ids,
      start_at, start_at
    )

    accessed_hours = accesses.group_by_hour(:created_at).count
    #168 hours per week
    (0..167).map do |hour|
      access_time = start_at + hour.hours
      count = accessed_hours[access_time] || 0
      {access_time.in_time_zone(time_zone_name) => scale_count(count)}
    end
  end

  private
  def time_zone_name
    time_zone.name
  end

  def working_denominator(arr)
    arr.none? ? 1 : arr.size
  end

  def calculate_progress(student)
    cp = CourseProgress.new(self, student.user)
    req_count = cp.requirement_count.zero? ? 1 : cp.requirement_count
    (cp.requirement_completed_count.to_f / req_count.to_f) * 100
  end

  def get_relevant_student_alerts_count(student)
    return unless student
    AlertsService::Client.course_student_alerts(
      course_id: id,
      student_id: student.id,
    ).payload.size
  end

  def scale_count(count)
    return 0 if no_active_students?
    enrs = active_students.size
    return 10 if count >= enrs * 10
    count.divmod(enrs).first
  end
end
