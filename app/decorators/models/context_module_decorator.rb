ContextModule.class_eval do
  after_save :assign_threshold
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

  def validate_completion_requirements(requirements)
    requirements = requirements.map do |req|
      new_req = {
        id: req[:id].to_i,
        type: req[:type],
        overridden: req[:overridden]
      }
      new_req[:min_score] = req[:min_score].to_f if req[:type] == 'min_score' && req[:min_score]
      new_req
    end

    tags = self.content_tags.not_deleted.index_by(&:id)
    validated_reqs = requirements.select do |req|
      if req[:id] && (tag = tags[req[:id]])
        if %w(must_view must_mark_done must_contribute).include?(req[:type])
          true
        elsif %w(must_submit min_score).include?(req[:type])
          true if tag.scoreable?
        end
      end
    end

    unless self.new_record?
      old_requirements = self.completion_requirements || []
      validated_reqs.each do |req|
        if req[:type] == 'must_contribute' && !old_requirements.detect{|r| r[:id] == req[:id] && r[:type] == req[:type]} # new requirement
          tag = tags[req[:id]]
          if tag.content_type == "DiscussionTopic"
            @discussion_topics_to_recalculate ||= []
            @discussion_topics_to_recalculate << tag.content
          end
        end
      end
    end

    validated_reqs
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
      next if skippable_requirement?(requirement)
      update_score(requirement)
    end
  end

  def skippable_requirement?(requirement)
    requirement[:overridden] || !["must_submit", "must_contribute", "min_score"].include?(requirement[:type])
  end

  def update_score(requirement)
    requirement[:type] = "min_score"
    requirement[:min_score] = score_threshold
  end
end
