AccountsController.class_eval do
  def strongmind_settings
    grab_holidays
    @school_threshold = score_threshold
    @prevent_course_thresh = course_threshold_prevention_on?
    @module_editing_disabled = disable_module_editing_on?
    js_env({HOLIDAYS: @holidays})
    instructure_settings
  end

  alias_method :instructure_settings, :settings
  alias_method :settings, :strongmind_settings

  def strongmind_update
    @school_threshold = params[:account][:settings][:score_threshold].to_i
    set_school_threshold if valid_threshold?(@school_threshold)
    set_holidays if params[:holidays]
    set_course_threshold_prevention
    set_module_editing
    instructure_update
  end

  alias_method :instructure_update, :update
  alias_method :update, :strongmind_update

  private
  def holidays
    params[:holidays].blank? ? false : params[:holidays]
  end

  def grab_holidays
    @holidays = SettingsService.get_settings(object: :school, id: 1)['holidays']
    @holidays = @holidays.split(",") if @holidays
    @holidays ||= (ENV["HOLIDAYS"] && @holidays != false) ? ENV["HOLIDAYS"].split(",") : []
  end

  def set_holidays
    SettingsService.update_settings(
        object: 'school',
        id: 1,
        setting: 'holidays',
        value: holidays
      )
  end

  def set_school_threshold
    SettingsService.update_settings(
        object: 'school',
        id: 1,
        setting: 'score_threshold',
        value: @school_threshold
      )
  end

  def course_threshold_prevention_params
    params[:account][:settings][:prevent_thresholds_in_courses].to_i.positive?
  end

  def set_course_threshold_prevention
    SettingsService.update_settings(
        object: 'school',
        id: 1,
        setting: 'course_threshold_prevention',
        value: course_threshold_prevention_params
      )
  end

  def disable_module_editing_params
    params[:account][:settings][:prevent_module_editing].to_i.positive?
  end

  def set_module_editing
    SettingsService.update_settings(
        object: 'school',
        id: 1,
        setting: 'disable_module_editing',
        value: disable_module_editing_params
      )
  end
end
