ContextModule.class_eval do
  after_save :assign_threshold
  after_commit -> { PipelineService.publish(self, alias: 'module') }

  def assign_threshold
    return unless threshold_set? && threshold_changes_needed?
    add_min_score_to_requirements
    update_column(:completion_requirements, completion_requirements)
  end

  def force_min_score_to_requirements
    strip_overrides
    add_min_score_to_requirements
    update_column(:completion_requirements, completion_requirements)
    touch
  end

  private
  def score_threshold
    @score_threshold ||= SettingsService.get_settings(object: :course, id: course.try(:id))['passing_threshold'].to_f
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

  def get_threshold_overrides
    @threshold_overrides ||= SettingsService.get_settings(object: :course, id: course.try(:id))['threshold_overrides']
  end

  def has_threshold_override?(requirement)
    get_threshold_overrides.split(",").map(&:to_i).include?(requirement[:id]) if get_threshold_overrides
  end

  def strip_overrides
    SettingsService.update_settings(
      object: 'course',
      id: course.try(:id),
      setting: 'threshold_overrides',
      value: false
    )
  end

  def skippable_requirement?(requirement)
    has_threshold_override?(requirement) ||
    ["must_submit", "must_contribute", "min_score"].none? { |type| type == requirement[:type] }
  end

  def add_min_score_to_requirements
    completion_requirements.each do |requirement|
      next if skippable_requirement?(requirement)
      update_score(requirement)
    end
  end

  def update_score(requirement)
    requirement[:type] = "min_score"
    requirement[:min_score] = score_threshold
  end
end
