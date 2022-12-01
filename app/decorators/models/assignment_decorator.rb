Assignment.class_eval do
  after_commit -> { PipelineService.publish_as_v2(self) }
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

  def ensure_assignment_group(do_save = true)
    self.context.require_assignment_group
    assignment_groups = self.context.assignment_groups.active
    if !assignment_groups.map(&:id).include?(self.assignment_group_id)
      self.assignment_group = assignment_groups.find_by_name('Assignments') || assignment_groups.first
      save! if do_save
    end
  end
end
