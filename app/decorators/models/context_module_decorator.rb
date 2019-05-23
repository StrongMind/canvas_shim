ContextModule.class_eval do   
  serialize :completion_requirements, Array
  
  def score_threshold
    SettingsService.get_settings(object: :school, id: 1)['score_threshold']
  end
  
  def threshold_set?
    score_threshold.positive?
  end

  def assign_threshold
    return unless threshold_set?

    graded_requirements = completion_requirements.select {|req| ["must_submit", "must_contribute"].include?(req[:type]) }

    return if graded_requirements.none?
    
    completion_requirements.each do |requirement|
      if graded_requirements.include?(requirement)
        requirement[:type] = "min_score"
        requirement[:min_score] = score_threshold.to_f
      end
    end

    update_column(:completion_requirements, completion_requirements)
  end

  after_commit :assign_threshold
end