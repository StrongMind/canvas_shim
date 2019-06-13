Assignment.class_eval do
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
<<<<<<< HEAD
=======
    return false if user.nil?
>>>>>>> ffe2bd0d644fd159d386325bb077b805226f47e3
    excused_submissions.exists?(user_id: user.id)
  end
end
