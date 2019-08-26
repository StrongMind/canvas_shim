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
    handle_exclusions
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

  def handle_exclusions
    if @assignment && params['excluded_students']
      begin
        Assignment.transaction do
          params['excluded_students'].each do |student|
            @assignment.toggle_exclusion(student['id'].to_i, true)
          end
          unexcuse_assignments(params['excluded_students'])
        end
      rescue StandardError => exception
        Raven.capture_exception(exception)
      end
    end
  end

  def unexcuse_assignments(arr)
    student_ids = arr.map { |student| student['id'] }
    excused = @assignment.excused_submissions
    excused = excused.where("user_id NOT IN (?)", student_ids) if student_ids.any?
    excused.each do |sub|
      @assignment.toggle_exclusion(sub.user_id, false)
    end
  end

  def tiny_student_hash(group)
    group.map {|obj| {id: obj.user_id, name: obj.user.name} }
  end

  def excused_students
    submissions = @assignment ? @assignment.excused_submissions : []
    tiny_student_hash(submissions)
  end

  def get_discussion_assignment
    @assignment = @context.discussion_topics.find(params[:id])&.assignment
  end
end
