AssignmentsController.class_eval do
  def tiny_student_hash(group)
    group.map {|obj| {id: obj.user_id, name: obj.user.name} }
  end

  def students_in_course
    tiny_student_hash(@context.student_enrollments.where(type: "StudentEnrollment"))
  end

  def excused_students
    tiny_student_hash(@assignment.submissions.where(excused: true))
  end

  def strongmind_update
    instructure_update
  end

  alias_method :instructure_update, :update
  alias_method :update, :strongmind_update
end