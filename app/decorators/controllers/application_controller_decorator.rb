ApplicationController.class_eval do
  prepend_view_path CanvasShim::Engine.root.join('app', 'views')

  def custom_placement_enabled?
    SettingsService.get_settings(object: :school, id: 1)['enable_custom_placement']
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

  private

  def student_names_ids(group)
    group.map {|obj| {id: obj.user_id, name: obj.user.name} }
  end

  def students_in_course
    student_names_ids(@context.student_enrollments.where(type: "StudentEnrollment"))
  end

  def excused_students
    student_names_ids(@assignment.excused_submissions)
  end

  def handle_exclusions
    exclusions = excused_params
    if @assignment && excused_params_present?
      begin
        Assignment.transaction do
          exclusions.each do |student|
            @assignment.toggle_exclusion(student['id'].to_i, true)
          end
          unexcuse_assignments(exclusions)
        end
      rescue StandardError => exception
        Raven.capture_exception(exception)
      end
    end
  end

  def unexcuse_assignments(arr)
    student_ids = arr.map { |student| student['id'] }
    excused = @assignment.excused_submissions
    excused = excused.where("user_id NOT IN (?)", student_ids) if student_ids.any?
    excused.each do |sub|
      @assignment.toggle_exclusion(sub.user_id, false)
    end
  end
end
