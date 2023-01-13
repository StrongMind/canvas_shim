AccountsController.class_eval do

  def show_account_by_uuid
    @account = Account.find_by(uuid: params[:account_uuid].split(":").last)

    return render :json => {
        message: "No account found with this uuid."
      }, :status => :not_found unless @account

    show
  end

  def strongmind_settings
    grab_holidays
    get_allowed_filetypes
    get_first_assignment_due
    get_last_assignment_due
    course_start_time = DateTime.parse(get_course_start_time)
    course_end_time = DateTime.parse(get_course_end_time)
    @course_start_time_hour = course_start_time.strftime("%I")
    @course_start_time_minute = course_start_time.strftime("%M")
    @course_start_time_ampm = course_start_time.strftime("%p")

    @course_end_time_hour = course_end_time.strftime("%I")
    @course_end_time_minute = course_end_time.strftime("%M")
    @course_end_time_ampm = course_end_time.strftime("%p")

    @course_thresh_enabled    = RequirementsService.course_threshold_setting_enabled?
    @assignment_group_thresholds = get_assignment_group_thresholds(passing_threshold_group_names)
    if @course_thresh_enabled
      @post_enrollment_thresh_enabled = RequirementsService.post_enrollment_thresholds_enabled?
    end

    @module_editing_disabled = RequirementsService.disable_module_editing_on?

    @expose_first_and_last_assignment_due_date_field = Rails.configuration.launch_darkly_client.variation("expose-first-and-last-assignment-due-date-field", launch_darkly_user, false)
    @expose_discussion_and_project_threshold_field = Rails.configuration.launch_darkly_client.variation("expose-discussion-and-project-threshold-field", launch_darkly_user, false)
    @expose_default_course_access_times = Rails.configuration.launch_darkly_client.variation("expose-default-course-access-times", launch_darkly_user, false)

    js_env({
      HOLIDAYS: @holidays,
      FILETYPES: @allowed_filetypes
    })
    instructure_settings
  end

  alias_method :instructure_settings, :settings
  alias_method :settings, :strongmind_settings

  def strongmind_update
    if account_settings_params
      if account_settings_params.keys.select{|k| k.match(/(_passing_threshold)/)}.any?
        set_assignment_group_thresholds(passing_threshold_group_names)
        update_course_passing_requirements
      end
      set_threshold_permissions

      set_allowed_filetypes if params[:allowed_filetypes]
      set_holidays if params[:holidays]
      set_first_assignment_due if account_settings_params[:first_assignment_due]
      set_last_assignment_due if account_settings_params[:last_assignment_due]
      set_course_start_time
      set_course_end_time
    end

    instructure_update
  end

  alias_method :instructure_update, :update
  alias_method :update, :strongmind_update

  def assign_observers
    @active_tab = "assign_observers"
    js_env(BASE_URL: request.base_url)
  end

  private
  def holidays
    params[:holidays].blank? ? false : params[:holidays]
  end

  def allowed_filetypes
    params[:allowed_filetypes].blank? ? false : params[:allowed_filetypes]
  end

  def first_assignment_due
    account_settings_params[:first_assignment_due].present? ? account_settings_params[:first_assignment_due] : false
  end

  def last_assignment_due
    account_settings_params[:last_assignment_due].present? ? account_settings_params[:last_assignment_due] : false
  end


  def grab_holidays
    @holidays = SettingsService.get_settings(object: :school, id: 1)['holidays']
    @holidays = @holidays.split(",") if @holidays
    @holidays ||= (ENV["HOLIDAYS"] && @holidays != false) ? ENV["HOLIDAYS"].split(",") : []
  end

  def get_allowed_filetypes
    @allowed_filetypes = SettingsService.get_settings(object: 'school', id: 1)['allowed_filetypes']
    @allowed_filetypes = @allowed_filetypes.split(',') if @allowed_filetypes
    @allowed_filetypes = [] unless @allowed_filetypes
  end

  def set_holidays
    SettingsService.update_settings(
      object: 'school',
      id: 1,
      setting: 'holidays',
      value: holidays
    )
  end

  def set_allowed_filetypes
    SettingsService.update_settings(
      object: 'school',
      id: 1,
      setting: 'allowed_filetypes',
      value: allowed_filetypes
    )
  end

  def course_threshold_enablement_params
    params[:account][:settings][:enable_thresholds_in_courses].to_i.positive?
  end

  def disable_module_editing_params
    params[:account][:settings][:prevent_module_editing].to_i.positive?
  end

  def enable_post_enrollment_threshold_params
    params[:account][:settings][:enable_post_enrollment_threshold_updates].to_i.positive?
  end

  def set_threshold_permissions
    RequirementsService.set_threshold_permissions(
      course_thresholds: course_threshold_enablement_params,
      post_enrollment: enable_post_enrollment_threshold_params,
      module_editing: disable_module_editing_params,
    )
  end

  def get_first_assignment_due
    @first_assignment_due = SettingsService.get_settings(object: 'school', id: 1)['first_assignment_due']
  end

  def get_last_assignment_due
    @last_assignment_due = SettingsService.get_settings(object: 'school', id: 1)['last_assignment_due']
  end

  def get_course_start_time
    SettingsService.get_settings(object: 'school', id: 1)['course_start_time'] || "12:00 AM"
  end

  def get_course_end_time
    SettingsService.get_settings(object: 'school', id: 1)['course_end_time'] || "11:59 PM"
  end

  def set_first_assignment_due
    SettingsService.update_settings(
      object: 'school',
      id: 1,
      setting: 'first_assignment_due',
      value: first_assignment_due
    )
  end

  def set_last_assignment_due
    SettingsService.update_settings(
      object: 'school',
      id: 1,
      setting: 'last_assignment_due',
      value: last_assignment_due
    )
  end

  def set_course_start_time
    start_time_hour = "#{params[:account][:settings]['course_start_time_hour']}"
    start_time_minute = "#{params[:account][:settings]['course_start_time_minute']}"
    ampm = "#{params[:account][:settings]['course_start_time_ampm']}"
    start_time = "#{start_time_hour}:#{start_time_minute} #{ampm}"

    SettingsService.update_settings(
      object: 'school',
      id: 1,
      setting: 'course_start_time',
      value: start_time
    )
  end

  def set_course_end_time
    end_time_hour = "#{params[:account][:settings]['course_end_time_hour']}"
    end_time_minute = "#{params[:account][:settings]['course_end_time_minute']}"
    ampm = "#{params[:account][:settings]['course_end_time_ampm']}"
    end_time = "#{end_time_hour}:#{end_time_minute} #{ampm}"

    SettingsService.update_settings(
      object: 'school',
      id: 1,
      setting: 'course_end_time',
      value: end_time
    )
  end

  def get_assignment_group_thresholds(assignment_group_names)
    thresholds = {}
    assignment_group_names.each do |group_name|
      thresholds[group_name] = RequirementsService.get_passing_threshold(type: 'school', assignment_group_name: group_name)
    end
    thresholds
  end

  def set_assignment_group_thresholds(assignment_group_names)
    assignment_group_names.each do |group_name|
      threshold_name = "#{group_name}_passing_threshold"
      threshold_edited = "#{group_name}_passing_threshold_edited"
      RequirementsService.set_passing_threshold(
        type: "school",
        threshold: account_settings_params[threshold_name].to_f,
        edited: params[threshold_edited],
        assignment_group_name: group_name
      )
    end
  end

  def update_course_passing_requirements
    @account.update_course_passing_requirements
  end

  def passing_threshold_group_names
    AssignmentGroup.passing_threshold_group_names
  end

  private

  def account_settings_params
    params[:account][:settings]
  end
end
