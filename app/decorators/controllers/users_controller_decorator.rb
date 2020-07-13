UsersController.class_eval do
  def observer_enrollments
    user = User.find(params[:id])
    return render_unauthorized_action unless user
    contexts = user.observer_enrollments.map(&:course)
    observed_enrollments = ObserverEnrollment.observed_enrollments_for_courses(contexts, user)
    .group_by(&:user_id)
    .map do |k, v|
      user = User.find(k)
      {
        "user" => user.as_json(include_root: false).merge(
          {
            "avatar_image_url" => avatar_image_attrs(k).first,
            "is_online" => user.is_online?,
            "locked_out" => locked_out(user)
          }),
        "enrollments" => v.map do |enr|
          enr.as_json(include_root: false).merge(
            {
              "score" => enr.scores.first,
              "course_name" => enr.course.name
            })
        end
      }
    end.as_json(include_root: false)

    render :json => observed_enrollments, :status => :ok
  end

  def locked_out(student)
    sis_id = student.pseudonyms.first&.sis_user_id
    call_to_strongmind_psp(sis_id) if sis_id
  end

  def toggle_progress_grade
    user = User.find(params[:id])
    return render_unauthorized_action unless user

    SettingsService.update_settings(
      object: 'user',
      id: user.id,
      setting: "show_progress_grades",
      value: params["show_progress_grades"]
    )

    render :json => {show_progress_grades: params["show_progress_grades"]}, :status => :ok
  end

  def soft_save_with_or_without_identity(user, email)
    begin
      User.transaction { user.save_with_or_without_identity(email) }
    rescue
      false
    end
  end
end