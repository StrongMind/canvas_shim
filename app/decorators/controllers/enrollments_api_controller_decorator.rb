EnrollmentsApiController.class_eval do
  before_action :get_course_from_section, except: :custom_placement
  before_action :require_context

  def custom_placement
    if !custom_placement_enabled?
      render(:json => { error: 'Custom placement not enabled' }, :status => :unprocessable_entity) and return
    end

    @enrollment  = @context.enrollments.find(params[:id])
    @content_tag = ContentTag.find(params[:content_tag].dig(:id))

    if @enrollment && @content_tag
      # Auto accept invite if pending
      @enrollment.accept if @enrollment.invited?
      @enrollment.user.send_later_if_production_enqueue_args(:custom_placement_at, { priority: Delayed::HIGH_PRIORITY }, @content_tag)

      render :json => {}, :status => :ok
    else
      render :json => {}, :status => :unprocessable_entity
    end

  rescue StandardError => exception
    Raven.capture_exception(exception)
    render :json => {}, :status => :bad_request
  end

  def snapshot
    student = StudentEnrollment.find(params[:id])

    return render :json => {}, :status => :unprocessable_entity unless student

    render :json => {
      user: student.user,
      last_active: student.days_since_active,
      last_submission: student.days_since_last_submission,
      missing_assignments: student.missing_assignments_count,
      current_score: student.current_score,
      course_progress: "#{@context.calculate_progress(student, cached: true).round(1)}%",
      requirements_completed: student.string_progress,
      alerts: @context.get_relevant_alerts_count(student.user)
    }, status => :ok

  rescue StandardError => exception
    Raven.capture_exception(exception)
    render :json => {}, :status => :bad_request
  end

  def observer_popout
    student = StudentEnrollment.find(params[:id])
    return render :json => {}, :status => :unprocessable_entity unless student

    render :json => {
      last_active: student.days_since_active,
      last_submission: student.last_submission_formatted,
      missing_assignments: student.missing_assignments_count,
      course_progress: "#{@context.calculate_progress(student, cached: true).round(1)}%",
    }, status => :ok
  end
end
