DiscussionTopicsController.class_eval do
  before_action :get_discussion_assignment, only: :edit

  def strongmind_index
    @discussions = @context&.discussion_topics
    js_env(excused_discussions: excused_discussion_topics)
    instructure_index
  end

  alias_method :instructure_index, :index
  alias_method :index, :strongmind_index

  def strongmind_edit
    js_env(new_assignment: !get_discussion_assignment)
    instructure_edit
  end

  alias_method :instructure_edit, :edit
  alias_method :edit, :strongmind_edit

  def strongmind_update
    get_discussion_assignment
    ExcusedService.bulk_excuse(assignment: @assignment, exclusions: params['excluded_students'])
    ExcusedService.bulk_unassign(assignment: @assignment, assignment_params: params[:assignment])
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
end
