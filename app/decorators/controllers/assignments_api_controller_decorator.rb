AssignmentsApiController.class_eval do
  def strongmind_update
    @assignment = @context.active_assignments.api_id(params[:id])
    if @assignment && params['assignment'] && params['assignment']['excluded_students']
      params['assignment']['excluded_students'].each do |student|
        @assignment.toggle_exclusion(student['id'].to_i, true)
      end

      unexcuse_assignments(params['assignment']['excluded_students'])
    end

    instructure_update
  end

  alias_method :instructure_update, :update
  alias_method :update, :strongmind_update

  def unexcuse_assignments(arr)
    student_ids = arr.map { |student| student['id'] }
    @assignment.excused_submissions.where("user_id NOT IN (?)", student_ids).each do |sub|
      @assignment.toggle_exclusion(sub.user_id, false)
    end
  end
end