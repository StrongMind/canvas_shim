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
    ExcusedService.bulk_excuse(assignment: @assignment, exclusions: params['excluded_students'])
    instructure_update
    set_announcement_expiration_date?
  end

  alias_method :instructure_update, :update
  alias_method :update, :strongmind_update

  def strongmind_create
    instructure_create
    set_announcement_expiration_date?
  end

  alias_method :instructure_create, :create
  alias_method :create, :strongmind_create

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
    @assignment = @context.discussion_topics.find(params[:id] || params[:topic_id])&.assignment
  end

  def merge_unassign_params
    params[:assignment].merge!(bulk_unassign: params[:bulk_unassign]) if params[:assignment]
  end

  def set_announcement_expiration_date?
    unless @topic&.new_record? || @errors.any?
      send_announcement_expiration_date if @topic.is_announcement
    end
  end

  def send_announcement_expiration_date
    SettingsService.update_settings(
      object: 'announcement',
      id: @topic.id,
      setting: 'expiration_date',
      value: params["post_expiration_date"] || false
    )
  end
end
