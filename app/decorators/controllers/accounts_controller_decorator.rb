AccountsController.class_eval do
  def strongmind_settings
    grab_holidays
    @threshold = SettingsService.get_settings(object: :school, id: 1)['score_threshold']
    js_env({HOLIDAYS: @holidays})
    instructure_settings
  end

  alias_method :instructure_settings, :settings
  alias_method :settings, :strongmind_settings

  def strongmind_update
    if params[:holidays]
      SettingsService.update_settings(
        object: 'school',
        id: 1,
        setting: 'holidays',
        value: holidays
      )
    end

    @threshold = params[:account][:settings][:score_threshold].to_i

    if valid_threshold?
      SettingsService.update_settings(
        object: 'school',
        id: 1,
        setting: 'score_threshold',
        value: @threshold
      )
    end

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

  def valid_threshold?
    !@threshold.negative? && @threshold <= 100
  end
end
