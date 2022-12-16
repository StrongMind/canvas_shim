ContextModule.class_eval do
  after_save :assign_threshold
  after_commit -> { PipelineService.publish_as_v2(self, alias: 'module') }

  def assign_threshold
    if completion_requirements_was&.empty?
      RequirementsService.apply_minimum_scores(context_module: self, assignment_group_names: AssignmentGroup.passing_threshold_group_names)
    end
  end

  def update_threshold_reqs
    passing_thresholds = SettingsService.get_settings(object: 'course', id: self.course.try(:id))
    assignment_overrides = get_assignment_threshold_overrides
    self.completion_requirements.each do |req|
      next unless req[:type] == 'min_score'
      next if assignment_overrides&.include?(req[:id])
      content_tag = ContentTag.find(req[:id])
      assignment_group_name = case content_tag.content_type
                              when 'DiscussionTopic'
                                content_tag.content.assignment.passing_threshold_group_name
                              when 'Assignment'
                                content_tag.content.passing_threshold_group_name
                              else
                                next
                              end
      value = passing_thresholds["#{assignment_group_name}_passing_threshold"]
      req[:min_score] = value
    end
    self.update_column(:completion_requirements, self.completion_requirements)
    self.touch
  end
  handle_asynchronously :update_threshold_reqs

  def get_assignment_threshold_overrides
    SettingsService.get_settings(object: 'course', id: self.course.try(:id))['threshold_overrides']
  end
end
