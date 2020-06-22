ApplicationController.class_eval do

  prepend_view_path CanvasShim::Engine.root.join('app', 'views')

  def custom_placement_enabled?
    @current_user && @context.is_a?(Course) &&
    @current_user.roles(Account.default).include?("admin") ||
    @current_user.teacher_enrollments.find_by(course: @context)&.has_permission_to?(:custom_placement) ||
    @current_user.ta_enrollments.find_by(course: @context)&.has_permission_to?(:custom_placement)
  end

  def strongmind_update_enrollment_last_activity_at
    return if logged_in_user != @current_user
    instructure_update_enrollment_last_activity_at
  end

  alias_method :instructure_update_enrollment_last_activity_at, :update_enrollment_last_activity_at
  alias_method :update_enrollment_last_activity_at, :strongmind_update_enrollment_last_activity_at

  def strongmind_content_tag_redirect(context, tag, error_redirect_symbol, tag_type=nil)
    if @maxed_out && tag.locked_for?(@current_user)
      maxout_message = <<~DESC
        You have not met the minimum requirements for your last activity.
        Please contact your teacher to proceed.
      DESC
      flash[:error] = t(maxout_message)
    end
    instructure_content_tag_redirect(context, tag, error_redirect_symbol, tag_type)
  end

  alias_method :instructure_content_tag_redirect, :content_tag_redirect
  alias_method :content_tag_redirect, :strongmind_content_tag_redirect

  def hide_destructive_course_options?
    @hide_destructive_course_options ||= destructive_options_hidden?
  end

  def strongmind_badge_counts_for(context, user, enrollment=nil)
    counts = instructure_badge_counts_for(context, user, enrollment)
    counts['people'] = context.try(:online_user_count)
    counts
  end

  alias_method :instructure_badge_counts_for, :badge_counts_for
  alias_method :badge_counts_for, :strongmind_badge_counts_for

  def observer_dashboard_enabled?
    SettingsService.get_settings(object: 'school', id: 1)['observer_dashboard'] &&
    @current_user && (
      @current_user.roles(@domain_root_account).include?('admin') ||
      @current_user.observer_enrollments.active.any?
    )
  end

  helper_method :observer_dashboard_enabled?

  private
  def destructive_options_hidden?
    get_context
    return false if @current_user && @current_user.roles(@domain_root_account).include?('admin')
    SettingsService.get_settings(object: :school, id: 1)['hide_destructive_course_options']
  end
end
