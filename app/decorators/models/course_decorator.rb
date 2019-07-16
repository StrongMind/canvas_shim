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
      cp = CourseProgress.new(self, student.user)
      (cp.requirement_completed_count.to_f / cp.requirement_count.to_f) * 100
    end.reduce(&:+).to_f / working_denominator(active_students)
  end

  def needs_grading_count
    assignments.map(&:needs_grading_count).reduce(&:+).to_i
  end

  private
  def working_denominator(arr)
    arr.none? ? 1 : arr.size
  end
end
