Assignment.class_eval do
  # after_commit -> { PipelineService.publish_as_v2(self) }
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
end
