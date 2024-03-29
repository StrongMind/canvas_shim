CoursesController.class_eval do
  helper_method :enrollment_name, :user_can_conclude_enrollments?
  after_action :clean_up_session_keys, only: [:settings]

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
        Sentry.capture_exception(exception)
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

  def due_date_wizard
    @course = Course.find_by(id: params[:id])
    if authorized_action(@course, @current_user, :manage_assignments)
      js_env(
        course: @course.as_json(include_root: false),
        dates_distributing: AssignmentsService.is_distributing?(@course),
        currently_importing: currently_importing?(@course)
      )
    end
  end

  def distribute_due_dates
    get_context
    if authorized_action(@context, @current_user, :manage_assignments) && dates_distributable?
      AssignmentsService.distribute_dates_job(course: @context)
      render :json => {}, :status => :ok
    elsif currently_importing?(@context)
      render :json => {errors: "Currently Importing Content."}, :status => :unprocessable_entity
    else
      render :json => {}, :status => :unauthorized
    end
  end

  def clear_due_dates
    get_context
    if currently_importing?(@context)
      render :json => {errors: "Currently Importing Content."}, :status => :unprocessable_entity
    elsif authorized_action(@context, @current_user, :change_course_state)
      AssignmentsService.clear_due_dates(course: @context)
      render :json => {}, :status => :ok
    else
      render :json => {}, :status => :unauthorized
    end
  end

  def user_can_conclude_enrollments?
    first_student_enrollment = @context.enrollments.find_by(type: "StudentEnrollment")
    @current_user && first_student_enrollment && first_student_enrollment.can_be_concluded_by(@current_user, @context, session)
  end

  def strongmind_show
    instructure_show
    if @context
      passing_thresholds = RequirementsService.get_assignment_group_passing_thresholds(context: @context)
    end
    js_env(passing_thresholds: passing_thresholds) if passing_thresholds
    js_env(module_editing_disabled: RequirementsService.disable_module_editing_on?)
  end

  alias_method :instructure_show, :show
  alias_method :show, :strongmind_show


  def strongmind_settings
    @expose_course_level_passing_threshold_fields = Rails.configuration.launch_darkly_client.variation("expose-course-level-passing-threshold-fields", @launch_darkly_user, false)
    @assignment_group_thresholds = get_course_thresholds(passing_threshold_group_names)
    get_course_dates
    hide_destructive_course_options?
    js_env(relock_warning: session[:relock_warning])
    instructure_settings
  end

  alias_method :instructure_settings, :settings
  alias_method :settings, :strongmind_settings

  def strongmind_update
    instructure_update
    return if params[:course].blank?
    session[:relock_warning] = false
    if authorized_action(@course, @current_user, [:update, :manage_content, :change_course_state])
      passing_thresholds_edited = params.select { |k, v| k.match(/(_passing_threshold_edited)/) && v == "true" }.present?
      if course_settings_params
        if course_settings_params.keys.select { |k| k.match(/(_passing_threshold)/) }.any? && passing_thresholds_edited
          thresholds_to_update = determine_assignment_group_overrides
          assignment_group_names = thresholds_to_update['assignment_group_names']
          set_assignment_group_threshold_overrides(thresholds_to_update['override_group_names'])
          set_assignment_group_thresholds(assignment_group_names)
          RequirementsService.force_min_scores(course: @course, assignment_group_names: assignment_group_names)
          session[:relock_warning] = true
        end
      end
    end
  end

  alias_method :instructure_update, :update
  alias_method :update, :strongmind_update

  def strongmind_copy
    return render_unauthorized_action if hide_destructive_course_options?
    instructure_copy
    display_wo_auto_due_dates?
  end

  alias_method :instructure_copy, :copy
  alias_method :copy, :strongmind_copy

  def strongmind_copy_course
    start_at = DateTime.parse(params[:course][:start_at]) rescue nil
    conclude_at = DateTime.parse(params[:course][:conclude_at]) rescue nil

    unless start_at && conclude_at
      flash[:error] = t("Please incude a start and end date.")
      get_context
      display_wo_auto_due_dates?
      return render 'copy'
    end

    instructure_copy_course
  end

  alias_method :instructure_copy_course, :copy_course
  alias_method :copy_course, :strongmind_copy_course

  def snapshot
    get_context
    if authorized_action(@context, @current_user, :manage_grades)
      set_snapshot_variables
    end
  end

  def passing_threshold_group_names
    AssignmentGroup.passing_threshold_group_names
  end

  def relock
    if authorized_action(@course, @current_user, [:update, :manage_content, :change_course_state])
      @course = Course.find_by(id: params[:course_id])
      @course.relock

      respond_to do |format|
        format.html { redirect_to course_settings_url }
        format.json { render :json => {} }
      end
    end
  end

  private

  def grade_out_users_params
    params.permit(enrollment_ids: [])
  end

  def get_course_thresholds(assignment_group_names)
    @threshold_visible = threshold_ui_allowed?
    return unless @threshold_visible
    thresholds = {}
    assignment_group_names.each do |group_name|
      thresholds[group_name] = RequirementsService.get_passing_threshold(type: 'course', id: params[:course_id], assignment_group_name: group_name)
    end
    thresholds
  end

  def set_assignment_group_thresholds(assignment_group_names)
    assignment_group_names.each do |group_name|
      threshold_name = "#{group_name}_passing_threshold"
      threshold_edited = "#{group_name}_passing_threshold_edited"
      RequirementsService.set_passing_threshold(
        type: "course",
        threshold: course_settings_params[threshold_name].to_f,
        edited: params[threshold_edited],
        id: @course.id,
        assignment_group_name: group_name
      )
    end
  end

  def set_assignment_group_threshold_overrides(override_group_names)
    SettingsService.update_settings(
      object: 'course',
      id: @course.id,
      setting: 'assignment_group_threshold_overrides',
      value: override_group_names.join(',')
    )
  end

  def determine_assignment_group_overrides
    school_thresholds = SettingsService.get_settings(object: 'school', id: 1).select{ |s| s.match?(/(_passing_threshold)$/) }
    existing_overrides = SettingsService.get_settings(object: 'course', id: @course.id)['assignment_group_threshold_overrides']
    course_thresholds = course_settings_params.select{|k,v| k.match(/(_passing_threshold)$/)}.to_unsafe_h
    assignment_group_names = []
    override_group_names = []
    course_thresholds.each_pair do |setting_name, value|
      group_name = setting_name.gsub(/(_passing_threshold)$/, '')
      if school_thresholds[setting_name.to_s] != value.to_i
        assignment_group_names << group_name
        override_group_names << group_name
      elsif school_thresholds[setting_name.to_s] == value.to_i && existing_overrides&.include?(setting_name.to_s.gsub(/(_passing_threshold)$/, ''))
        assignment_group_names << group_name
      end
    end
    {'assignment_group_names'=>assignment_group_names, 'override_group_names'=>override_group_names}
  end

  def threshold_ui_allowed?
    RequirementsService.course_threshold_setting_enabled? &&
    (!!@current_user&.enrollments&.find_by(type: 'TeacherEnrollment') || @current_user&.roles(Account.site_admin)&.include?('admin')) &&
    no_active_students_or_post_thresh?
  end

  def no_active_students_or_post_thresh?
    get_context
    RequirementsService.post_enrollment_thresholds_enabled? ? true : @context.try(:no_active_students?)
  end

  def display_wo_auto_due_dates?
    add_on = (SettingsService.get_settings(object: :school, id: 1)['auto_due_dates'] == 'on')
    js_env(auto_due_dates: add_on)
  end

  def course_snapshot_course_urls
    enrollments = @current_user.try(:teacher_enrollments) || []
    enrollments.reject do |enr|
      course = enr.course
      course.deleted? || course.no_active_students?
    end.map {|enr| [enr.course, course_snapshot_path(enr.course)] }
  end

  def context_not_in_snapshot?
    @course_list.none? { |item| item.first == @context }
  end

  def set_snapshot_variables
    @active_tab = "course-snapshot"
    @course_list ||= course_snapshot_course_urls
    @is_blank = context_not_in_snapshot?
    @avg_grade = @context.average_score.round(1)
    @assignments_need_grading = @context.needs_grading_count
    @alerts_need_attention = @context.get_relevant_alerts_count(@current_user)
    @active_students ||= @context.snapshot_students
    @student_count ||= @active_students.count
    @accesses_per_hour = @context.get_accesses_by_hour
  end

  def set_js_course_wizard_data
    # Course Wizard JS Info
    js_env({:COURSE_WIZARD => {
      :just_saved =>  @context_just_saved,
      :checklist_states => {
        :import_step => !@context.attachments.active.exists?,
        :assignment_step => !@context.assignments.active.exists?,
        :add_student_step => !@context.students.exists?,
        :navigation_step => @context.tab_configuration.empty?,
        :home_page_step => true, # The current wizard just always marks this as complete.
        :calendar_event_step => !@context.calendar_events.active.exists?,
        :add_ta_step => !@context.tas.exists?,
        :publish_step => @context.workflow_state === "available"
      },
      :urls => {
        :content_import => context_url(@context, :context_content_migrations_url),
        :add_assignments => context_url(@context, :context_assignments_url, :wizard => 1),
        :add_students => course_users_path(course_id: @context),
        :add_files => context_url(@context, :context_files_url, :wizard => 1),
        :select_navigation => context_url(@context, :context_details_url),
        :course_calendar => calendar_path(course_id: @context),
        :add_tas => course_users_path(:course_id => @context),
        :publish_course => course_path(@context)
      },
      :permissions => {
        # Sending the permissions just so maybe later we can extract this easier.
        :can_manage_content => can_do(@context, @current_user, :manage_content),
        :can_manage_students => can_do(@context, @current_user, :manage_students),
        :can_manage_assignments => can_do(@context, @current_user, :manage_assignments),
        :can_manage_files => can_do(@context, @current_user, :manage_files),
        :can_update => can_do(@context, @current_user, :update),
        :can_manage_calendar => can_do(@context, @current_user, :manage_calendar),
        :can_manage_admin_users => can_do(@context, @current_user, :manage_admin_users),
        :can_change_course_state => can_do(@context, @current_user, :change_course_state)
      }
    }
    })
  end

  def get_course_dates
    get_context
    js_env(
      start_date: @context.start_at.try(:strftime, "%m-%d-%Y"),
      end_date: @context.end_at.try(:strftime, "%m-%d-%Y")
    )
  end

  def dates_distributable?
    @context.is_a?(Course) && @context.start_at && @context.end_at && !currently_importing?(@context)
  end

  def currently_importing?(context)
    return @currently_importing unless @currently_importing.nil?
    @currently_importing = context.content_migrations.exists?(workflow_state: "importing")
  end

  def course_settings_params
    params[:course][:settings]
  end

  def clean_up_session_keys
    session.delete(:relock_warning) if session[:relock_warning].present?
  end
end
