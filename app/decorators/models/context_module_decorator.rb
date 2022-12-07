ContextModule.class_eval do
  after_save :assign_threshold
  after_commit -> { PipelineService.publish_as_v2(self, alias: 'module') }

  def assign_threshold
    if completion_requirements_was&.empty?
      RequirementsService.apply_minimum_scores(context_module: self)
    end
  end

  def update_threshold_reqs
    passing_thresholds = SettingsService.get_settings(object: 'course', id: self.course.try(:id))
    self.completion_requirements.each do |req|
      next unless req[:type] == 'min_score'
      content_tag = ContentTag.find(req[:id])
      assignment_group_name = content_tag.content_type == 'DiscussionTopic' ? content_tag.content.assignment.passing_threshold_group_name : content_tag.content.passing_threshold_group_name
      value = passing_thresholds["#{assignment_group_name}_passing_threshold"]
      req[:min_score] = value
    end
    self.update_column(:completion_requirements, self.completion_requirements)
  end
  handle_asynchronously :update_threshold_reqs
end
