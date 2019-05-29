CoursesController.class_eval do

  helper_method :enrollment_name, :user_can_conclude_enrollments?

  def show_course_enrollments
    get_context
    unless user_can_conclude_enrollments?
      authorized_action(@context, @current_user, :permission_fail)
    end

    # filter out fake students
    @student_enrollments = @context.student_enrollments.where(type: "StudentEnrollment")
  end

  def conclude_users
    get_context
    if user_can_conclude_enrollments?
      begin
        if grade_out_users_params[:enrollment_ids]
          Enrollment.transaction do
            grade_out_users_params[:enrollment_ids].each do |id|
              _conclude_user(id)
            end
          end
        end
        flash.now[:notice] = t("The selected students have been graded out successfully.")
      rescue StandardError => exception
        Raven.capture_exception(exception)
        flash.now[:error] = t("Something went wrong. Please try again.")
      ensure
        @student_enrollments = @context.student_enrollments.where(type: "StudentEnrollment")
        render 'show_course_enrollments'
      end
    else
      authorized_action(@context, @current_user, :permission_fail)
    end
  end

  def _conclude_user(id)
    @enrollment = @context.enrollments.find(id)

    if @enrollment.can_be_concluded_by(@current_user, @context, session)
      @enrollment.conclude
    else
      authorized_action(@context, @current_user, :permission_fail)
    end
  end

  def enrollment_name(enrollment)
    case enrollment.type
    when "StudentEnrollment"
      "Student"
    when "TeacherEnrollment"
      "Teacher"
    when "TaEnrollment"
      "T.A."
    when "ObserverEnrollment"
      "Observer"
    when "DesignerEnrollment"
      "Designer"
    end
  end

  def user_can_conclude_enrollments?
    first_student_enrollment = @context.enrollments.find_by(type: "StudentEnrollment")
    @current_user && first_student_enrollment && first_student_enrollment.can_be_concluded_by(@current_user, @context, session)
  end

  def strongmind_show
    instructure_show
    js_env(score_threshold: score_threshold.to_s) if threshold_set?
  end

  alias_method :instructure_show, :show
  alias_method :show, :strongmind_show

  private
  def grade_out_users_params
    params.permit(enrollment_ids: [])
  end
end
