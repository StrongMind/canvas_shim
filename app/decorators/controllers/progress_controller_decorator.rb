ProgressController.class_eval do
  def show_distribution_progress
    @course = Course.find(params[:course_id])
    progress = @course.progresses.where(
                  tag: "distribute_due_dates",
                  workflow_state: "running"
                ).last || Progress.new
    
    if authorized_action(@course, @current_user, :read)
      render :json => progress.as_json(include_root: false).merge(
        distributing: AssignmentsService.is_distributing?(@course)
      )
    end
  end
end