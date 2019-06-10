ContentMigration.class_eval do
  before_save :set_min_scores, if: :changed_and_imported?

  def set_min_scores
    course.context_modules.each(&:assign_threshold) if self.try(:course)
  end

  private
  def changed_and_imported?
    workflow_state_changed? && imported?
  end
end