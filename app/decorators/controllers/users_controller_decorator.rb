UsersController.class_eval do
  def observer_enrollments
    user = User.find(params[:id])
    return render_unauthorized_action unless user
    contexts = user.observer_enrollments.map(&:course)
    observed_enrollments = ObserverEnrollment.observed_enrollments_for_courses(contexts, user)
    .group_by(&:user_id)
    .map do |k, v|
      {
        "user" => User.find(k),
        "enrollments" => v.map do |enr|
          enr.as_json(include_root: false).merge({"score" => enr.scores.first})
        end
      }
    end.as_json(include_root: false)

    render :json => observed_enrollments, :status => :ok
  end
end