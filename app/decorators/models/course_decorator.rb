Course.class_eval do
  has_many :active_students, -> { where("enrollments.workflow_state NOT IN ('rejected', 'deleted', 'inactive', 'invited') AND enrollments.type = 'StudentEnrollment'").preload(:user) }, class_name: 'Enrollment'

  after_commit -> { PipelineService.publish(self) }
  #after_create :set_default_course_threshold if account_threshold_set?

  def force_min_scores
    context_modules.each(&:force_min_score_to_requirements)
  end

  def no_active_students?
    active_students.count.zero?
  end


  private
  def set_default_course_threshold
    # update dynamo
  end

  def account_threshold
    # get setting
  end

  def account_threshold_set?
    # account_threshold.to_i.positive?
  end
end
