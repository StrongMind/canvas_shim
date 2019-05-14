AccountsController.class_eval do
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