AssignmentsController.class_eval do
  def tiny_student_hash(group)
    group.map {|obj| {id: obj.user_id, name: obj.user.name} }
  end

  def students_in_course
    tiny_student_hash(@context.student_enrollments.where(type: "StudentEnrollment"))
  end

  def excused_students
    tiny_student_hash(@assignment.excused_submissions)
  end

  def current_user_excused?
    @assignment.is_excused?(@current_user)
  end

  def strongmind_show
    @assignment ||= @context.assignments.find(params[:id])
    if excused_students.any?
      @excused = excused_students.map { |stu| stu[:name] }.join(', ')
    else
      @excused = "No students currently excused from this assignment."
    end

    excused_description = <<~DESC
      <div class='ic-notification' style='background: rgba(255, 0, 0, .05);'>
      <h1 style='padding:1rem;'>You are excused from this assignment.</h1></div>
    DESC

    @assignment.description = excused_description if current_user_excused?
    instructure_show
  end

  alias_method :instructure_show, :show
  alias_method :show, :strongmind_show
end