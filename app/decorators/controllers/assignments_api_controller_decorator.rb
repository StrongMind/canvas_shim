AssignmentsApiController.class_eval do
  def strongmind_update
    instructure_update
    params[:excluded_students].each do |student|
      @assignment.toggle_exclusion(student.id)
    end
  end

  alias_method :instructure_update, :update
  alias_method :update, :strongmind_update
end