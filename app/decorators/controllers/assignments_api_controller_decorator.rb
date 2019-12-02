AssignmentsApiController.class_eval do
  def strongmind_update
    @assignment = @context.active_assignments.api_id(params[:id])
    bulk_excuse
    bulk_unassign
    instructure_update
  end

  alias_method :instructure_update, :update
  alias_method :update, :strongmind_update

  def strongmind_create
    instructure_create
    bulk_excuse
  end

  alias_method :instructure_create, :create
  alias_method :create, :strongmind_create

  private

  def exclusion_params
    params["assignment"]&.fetch("excluded_students", nil)
  end

  def bulk_excuse
    ExcusedService.bulk_excuse(assignment: @assignment, exclusions: exclusion_params)
  end

  def bulk_unassign
    ExcusedService.bulk_unassign(
      assignment: @assignment,
      assignment_params: params[:assignment],
      grader_id: @current_user.try(:id)
    )
  end
end
