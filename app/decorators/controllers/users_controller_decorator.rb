UsersController.class_eval do
  def observer_enrollments
    user = User.find(params[:id])
    return render_unauthorized_action unless user
    contexts = user.observer_enrollments.map(&:course)
    observed_enrollments = ObserverEnrollment.observed_enrollments_for_courses(contexts, user).group_by(&:user_id)
    render :json => observed_enrollments.as_json, :status => :ok
  end
end