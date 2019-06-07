ContentMigration.class_eval do
  before_save :set_min_scores, if: :workflow_state_changed?

  def set_min_scores
    if imported? && self.try(:course)
      course.context_modules.each(&:assign_threshold)
    end
  end
end