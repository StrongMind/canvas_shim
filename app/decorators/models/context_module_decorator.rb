ContextModule.class_eval do
  after_commit -> { PipelineService.publish(self, alias: 'module') }

  def assign_threshold
    return unless threshold_set? && threshold_changes_needed?
    add_min_score_to_requirements
    update_column(:completion_requirements, completion_requirements)
  end

  def force_min_score_to_requirements
    add_min_score_to_requirements
    update_column(:completion_requirements, completion_requirements)
    touch
  end

  private
  def course_score_threshold?
    threshold = SettingsService.get_settings(object: :course, id: course.try(:id))['passing_threshold'].to_f
    threshold if threshold.positive?
  end

  def account_score_threshold
    SettingsService.get_settings(object: :school, id: 1)['score_threshold'].to_f
  end

  def score_threshold
    @score_threshold ||= (course_score_threshold? || account_score_threshold)
  end

  def threshold_set?
    score_threshold.positive?
  end

  def threshold_changes_needed?
    completion_requirements.any? do |req|
      ["must_submit", "must_contribute"].include?(req[:type]) ||
      (req[:min_score] && req[:min_score] != score_threshold)
    end
  end

  def add_min_score_to_requirements
    completion_requirements.each do |requirement| 
      next unless ["must_submit", "must_contribute", "min_score"].include?(requirement[:type])
      update_score(requirement)
    end
  end

  def update_score(requirement)
    requirement[:type] = "min_score"
    requirement[:min_score] = score_threshold
  end
end
