UserObserveesController.class_eval do
  def bulk_create
    observee_ids.each do |obsv_id|
      bulk_add_observee(bulk_observee(obsv_id))
    end

    render json: observer.observed_users.map {|observee| observee.as_json(include_root: false)}
  end

  private
  def observee_ids
    @observee_ids ||= params.permit(observee_ids: []).fetch("observee_ids", [])
  end

  def observer
    @observer ||= api_find(User.active, params[:user_id])
  end

  def bulk_observee(id)
    api_find(User.active, id)
  end

  def bulk_add_observee(observee)
    observer.shard.activate do
      unless bulk_has_observee?(observee)
        observer.user_observees.create_or_restore(user_id: observee)
        observer.touch
      end
    end
  end

  def bulk_has_observee?(observee)
    observer.user_observees.active.where(user_id: observee).exists?
  end
end