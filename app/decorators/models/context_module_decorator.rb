ContextModule.class_eval do
  after_save :assign_threshold
  after_commit -> { PipelineService.publish(self, alias: 'module') }

  def assign_threshold
    return unless threshold_set? && threshold_changes_needed?(score_threshold)
    add_min_score_to_requirements(score_threshold)
    update_column(:completion_requirements, completion_requirements)
  end

  def force_min_score_to_requirements
    add_min_score_to_requirements(score_threshold)
    update_column(:completion_requirements, completion_requirements)
    touch
  end

  private
  def course_score_threshold?
    threshold = SettingsService.get_settings(object: :course, id: course.try(:id))['passing_threshold'].to_f
    threshold if threshold.positive?
  end

  def score_threshold
    course_score_threshold? || SettingsService.get_settings(object: :school, id: 1)['score_threshold'].to_f
  end

  def threshold_set?
    score_threshold.positive?
  end

  def threshold_changes_needed?(threshold)
    completion_requirements.any? do |req|
      ["must_submit", "must_contribute"].include?(req[:type]) ||
      (req[:min_score] && req[:min_score] != threshold)
    end
  end

  def add_min_score_to_requirements(threshold)
    completion_requirements.each { |requirement| update_score(requirement, threshold) }
  end

  def update_score(requirement, threshold)
    if ["must_submit", "must_contribute", "min_score"].include?(requirement[:type])
      requirement[:type] = "min_score"
      requirement[:min_score] = threshold
    end
  end
end
