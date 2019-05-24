ContextModulesController.class_eval do
  def strongmind_add_item
    instructure_add_item
    return unless gradeable_tag_type? && threshold_set?
    add_threshold_to_module
  end

  alias_method :instructure_add_item, :add_item
  alias_method :add_item, :strongmind_add_item

  private
  def gradeable_tag_type?
    %w{Assignment DiscussionTopic Quizzes::Quiz}.include?(@tag.content_type)
  end

  def score_threshold
    SettingsService.get_settings(object: :school, id: 1)['score_threshold'].to_f
  end
  
  def threshold_set?
    score_threshold.positive?
  end

  def add_threshold_to_module
    @module.completion_requirements << {:id => @tag.id, :type => "min_score", :min_score => score_threshold}
    @module.update_column(:completion_requirements, @module.completion_requirements)
  end
end
