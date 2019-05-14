AccountsController.class_eval do
  def strongmind_settings
    @holidays = SettingsService.get_settings(object: :school, id: 1)['holidays']
    @holidays = @holidays.split(",") if @holidays
    @holidays ||= ENV["HOLIDAYS"] ? ENV["HOLIDAYS"].split(",") : []
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
        value: params[:holidays]
      )
    end

    instructure_update
  end

  alias_method :instructure_update, :update
  alias_method :update, :strongmind_update
end