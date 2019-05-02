Assignment.class_eval do
  def exclude_student(student_id)
    submission = self.submissions.find_by(user_id: student_id)
    submission.update(excused: !submission.excused) if submission
  end
end