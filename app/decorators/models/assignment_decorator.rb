Assignment.class_eval do
  after_commit -> { PipelineService.publish_as_v2(self) }

  before_save :update_min_score_threshold, if: Proc.new { self.assignment_group_id_changed? && self.assignment_group_id_was != nil }

  def toggle_exclusion(student_id, bool)
    subs = submissions.where(user_id: student_id)
    if subs.any?
      subs.each do |submission|
        submission.update(excused: bool)
      end
    end
  end

  def excused_submissions
    submissions.where(excused: true)
  end

  def is_excused?(user)
    return false if user.nil?

    excused_submissions.exists?(user_id: user.id)
  end

  def assignment_group_name
    assignment_group.name
  end

  def passing_threshold_group_name
    assignment_group_name.strip.singularize.downcase.gsub(/\s/, "_")
  end

  def ensure_assignment_group(do_save = true)
    self.context.require_assignment_group
    assignment_groups = self.context.assignment_groups.active
    if !assignment_groups.map(&:id).include?(self.assignment_group_id)
      self.assignment_group = assignment_groups.find_by_name('Assignments') || assignment_groups.first
      save! if do_save
    end
  end

  def update_min_score_threshold
    content_tag = self.submission_types.include?('discussion_topic') ? ContentTag.find_by_content_id_and_content_type(self.discussion_topic.id, self.discussion_topic.class) : ContentTag.find_by_content_id_and_content_type(self.id, self.class)
    return unless content_tag
    context_module = content_tag.context_module
    group_name = self.passing_threshold_group_name
    if min_score_req = context_module.completion_requirements.select{ |r| r[:type] == 'min_score' && r[:id] == content_tag.id }.first
      context_module.completion_requirements.delete(min_score_req)
      passing_threshold = RequirementsService.get_passing_threshold(type: :course, id: self.course.try(:id), assignment_group_name: group_name)
      min_score_req[:min_score] = passing_threshold
      context_module.completion_requirements << min_score_req
      context_module.update_column(:completion_requirements, context_module.completion_requirements)
    else
      RequirementsService.add_unit_item_with_min_score(context_module: context_module, content_tag: content_tag, assignment_group_name: group_name)
    end
  end
end
