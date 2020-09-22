UserObserveesController.class_eval do
  def bulk_create
    observee_ids.each do |obsv_id|
      observee = api_find(User.active, obsv_id)
      observer.add_observee(observee)
    end

    render_observees_json
  end

  def bulk_destroy
    begin
      user.destroy_all_observations(observee_ids)
    rescue StandardError => exception
      Raven.capture_exception(exception)
      render :json => {}, :status => :bad_request
    end

    render_observees_json
  end

  private
  def observee_ids
    @observee_ids ||= params.permit(observee_ids: []).fetch("observee_ids", [])
  end

  def observer
    @observer ||= api_find(User.active, params[:user_id])
  end

  def render_observees_json
    render json: observer.observed_users.map {|observee| observee.as_json(include_root: false)}
  end
end