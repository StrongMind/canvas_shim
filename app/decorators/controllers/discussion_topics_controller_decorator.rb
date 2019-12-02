DiscussionTopicsController.class_eval do
  before_action :get_discussion_assignment, only: :edit

  def strongmind_index
    @discussions = @context&.discussion_topics
    js_env(excused_discussions: excused_discussion_topics)
    instructure_index
  end

  alias_method :instructure_index, :index
  alias_method :index, :strongmind_index

  def strongmind_update
    get_discussion_assignment
    merge_unassign_params
    ExcusedService.bulk_excuse(assignment: @assignment, exclusions: params['excluded_students'])
    ExcusedService.bulk_unassign(
      assignment: @assignment,
      assignment_params: params[:assignment],
      grader_id: @current_user.try(:id)
    )
    instructure_update
  end

  alias_method :instructure_update, :update
  alias_method :update, :strongmind_update

  private
  def excused_discussion_topics
    return [] unless topics_available?
    @discussions.map do |topic|
      topic.is_excused?(@current_user) ? "##{topic.id}_discussion_content" : nil
    end.compact
  end

  def topics_available?
    @discussions && @context.is_a?(Course) && @context.user_is_student?(@current_user)
  end

  def get_discussion_assignment
    @assignment = @context.discussion_topics.find(params[:id])&.assignment
  end

  def merge_unassign_params
    params[:assignment].merge!(bulk_unassign: params[:bulk_unassign]) if params[:assignment]
  end
end
