Assignment.class_eval do
  def exclude_student(student_id)
    subs = self.submissions.where(user_id: student_id)
    if subs.any?
      subs.each do |submission|
        submission.update(excused: !submission.excused)
      end
    end
  end
end