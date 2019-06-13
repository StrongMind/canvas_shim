CoursesController.class_eval do
  before_action :get_course_threshold, only: :settings
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
    js_env(score_threshold: score_threshold.to_s) if course_has_set_threshold?
    js_env(module_editing_disabled: disable_module_editing_on?)
  end

  alias_method :instructure_show, :show
  alias_method :show, :strongmind_show

  def strongmind_update
    instructure_update
    @course_threshold = params[:passing_threshold].to_i
    if !params[:course].blank? && threshold_edited? && can_update_threshold?
      set_course_passing_threshold
      CoursesService::Commands::ForceMinScores.new(course: @course).call
    end
  end

  alias_method :instructure_update, :update
  alias_method :update, :strongmind_update

  private
  def grade_out_users_params
    params.permit(enrollment_ids: [])
  end

  def can_update_threshold?
    @course && course_threshold_enabled? && valid_threshold?(@course_threshold)
  end

  def set_course_passing_threshold
    SettingsService.update_settings(
      object: 'course',
      id: @course.id,
      setting: 'passing_threshold',
      value: @course_threshold
    )
  end

  def get_course_threshold
    @threshold_visible = threshold_ui_allowed?
    return unless @threshold_visible
    @course_threshold = SettingsService.get_settings(object: :course, id: params[:course_id])['passing_threshold'].to_f
  end

  def threshold_ui_allowed?
    course_threshold_enabled? &&
    (!!@current_user.enrollments.find_by(type: 'TeacherEnrollment') || @current_user.roles(Account.site_admin).include?('admin')) &&
    no_active_students_or_post_thresh?
  end

  def no_active_students_or_post_thresh?
    get_context
    post_enrollment_thresholds_enabled? ? true : @context.try(:no_active_students?)
  end
end
