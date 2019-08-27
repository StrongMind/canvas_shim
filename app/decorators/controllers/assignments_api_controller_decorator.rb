AssignmentsApiController.class_eval do
  def strongmind_update
    @assignment = @context.active_assignments.api_id(params[:id])
    handle_exclusions
    instructure_update
  end

  alias_method :instructure_update, :update
  alias_method :update, :strongmind_update

  def strongmind_create
    instructure_create
    handle_exclusions
  end

  alias_method :instructure_create, :create
  alias_method :create, :strongmind_create

  private

  def excused_params
    return nil unless params['assignment']
    params['assignment']['excluded_students']
  end
end
