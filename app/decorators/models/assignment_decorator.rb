Assignment.class_eval do
  def toggle_exclusion(student_id, bool)
    subs = self.submissions.where(user_id: student_id)
    if subs.any?
      subs.each do |submission|
        submission.update(excused: bool)
      end
    end
  end

  def excused_submissions
    self.submissions.where(excused: true)
  end
end