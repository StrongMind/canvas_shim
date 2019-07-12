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
end
