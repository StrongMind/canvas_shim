AccountsController.class_eval do
  def strongmind_settings
    grab_holidays
    get_allowed_filetypes

    @school_threshold         = RequirementsService.get_passing_threshold(type: :school)
    @school_exam_threshold    = RequirementsService.get_passing_threshold(type: :school, exam: true)
    @course_thresh_enabled    = RequirementsService.course_threshold_setting_enabled?

    if @course_thresh_enabled
      @post_enrollment_thresh_enabled = RequirementsService.post_enrollment_thresholds_enabled?
    end

    @module_editing_disabled = RequirementsService.disable_module_editing_on?

    js_env({
      HOLIDAYS: @holidays,
      FILETYPES: @allowed_filetypes
    }) 
    instructure_settings
  end

  alias_method :instructure_settings, :settings
  alias_method :settings, :strongmind_settings

  def strongmind_update
    if params[:account][:settings]
      set_school_passing_threshold
      set_school_unit_exam_passing_threshold
      set_threshold_permissions

      set_allowed_filetypes if params[:allowed_filetypes]
      set_holidays if params[:holidays]
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

  def set_school_passing_threshold
    RequirementsService.set_passing_threshold(
      type: "school",
      threshold: params[:account][:settings][:score_threshold].to_f,
      edited: params[:threshold_edited]
    )
  end

  def set_school_unit_exam_passing_threshold
    RequirementsService.set_passing_threshold(
      type: "school",
      threshold: params[:account][:settings][:unit_score_threshold].to_f,
      edited: params[:unit_threshold_edited],
      exam: true
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
end
