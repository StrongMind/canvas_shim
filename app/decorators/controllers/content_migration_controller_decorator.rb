ContentMigrationsController.class_eval do 

  def strongmind_index
    js_env(:AUTO_DUE_DATES => SettingsService.get_settings(object: :school, id: 1)['auto_due_dates'] == 'on')
    instructure_index
  end

  alias_method :instructure_index, :index
  alias_method :index, :strongmind_index

end

