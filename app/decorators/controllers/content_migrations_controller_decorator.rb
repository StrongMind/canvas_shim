ContentMigrationsController.class_eval do

  def strongmind_index
    return render_unauthorized_action if hide_destructive_course_options?
    auto_due_dates = SettingsService.get_settings(object: :school, id: 1)['auto_due_dates'] == 'on'
    js_env(:AUTO_DUE_DATES => auto_due_dates)

    if auto_due_dates && (!@context.try(:start_at) || !@context.try(:conclude_at))
      js_env(:DUE_DATE_NAG => true)
    elsif auto_due_dates && SettingsService.get_settings(object: :course, id: @context&.id)['imported_content']
      js_env(:NO_AUTO_DATES_NAG => true)
    end

    instructure_index
  end

  alias_method :instructure_index, :index
  alias_method :index, :strongmind_index

end

