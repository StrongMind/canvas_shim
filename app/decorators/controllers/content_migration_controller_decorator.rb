ContentMigrationsController.class_eval do 

  def strongmind_index
    auto_due_dates = SettingsService.get_settings(object: :school, id: 1)['auto_due_dates'] == 'on'
    js_env(:AUTO_DUE_DATES => auto_due_dates)
    if auto_due_dates and !@context.try(:start_at) or !@context.try(:conclude_at)
      js_env(:DUE_DATE_NAG => true)
    else
      js_env(:DUE_DATE_NAG => false)
    end
    instructure_index
  end

  alias_method :instructure_index, :index
  alias_method :index, :strongmind_index

end

