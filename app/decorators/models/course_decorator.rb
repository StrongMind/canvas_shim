Course.class_eval do
  has_many :active_students, -> { where("enrollments.workflow_state NOT IN ('rejected', 'deleted', 'inactive', 'invited') AND enrollments.type = 'StudentEnrollment'").preload(:user) }, class_name: 'Enrollment'

  after_commit -> { PipelineService.publish(self) }

  def force_min_scores
    context_modules.each(&:force_min_score_to_requirements)
  end

  def no_active_students?
    active_students.count.zero?
  end
end
