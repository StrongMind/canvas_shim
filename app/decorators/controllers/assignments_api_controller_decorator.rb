AssignmentsApiController.class_eval do
  def strongmind_update
    @assignment = @context.active_assignments.api_id(params[:id])
    if @assignment && params['assignment'] && params['assignment']['excluded_students']
      params['assignment']['excluded_students'].each do |student|
        @assignment.toggle_exclusion(student['id'].to_i, true)
      end
    end
    instructure_update
  end

  alias_method :instructure_update, :update
  alias_method :update, :strongmind_update
end