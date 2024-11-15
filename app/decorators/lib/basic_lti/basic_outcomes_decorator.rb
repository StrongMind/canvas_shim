BasicLTI::BasicOutcomes::LtiResponse.class_eval do
  attr_accessor :submission

  def strongmind_create_homework_submission(_tool, submission_hash, assignment, user, new_score, raw_score)
    submissions = assignment.all_submissions.where(user_id: user.id)
    if submissions.present?
      @current_score = submissions.last.score
      @current_grade = submissions.last.grade
    end

    instructure_create_homework_submission(_tool, submission_hash, assignment, user, new_score, raw_score)

    if SettingsService.get_settings(object: :school, id: 1)['lti_keep_highest_score']
      update_submission_with_best_score
    end
  end

  alias_method :instructure_create_homework_submission, :create_homework_submission
  alias_method :create_homework_submission, :strongmind_create_homework_submission


  protected

  def strongmind_handle_replaceResult(_tool, _course, assignment, user)
    existing_submission = assignment.submissions.where(user_id: user.id).first
    return true if existing_submission&.excused?
    instructure_handle_replaceResult(_tool, _course, assignment, user)
  end

  alias_method :instructure_handle_replaceResult, :handle_replaceResult
  alias_method :handle_replaceResult, :strongmind_handle_replaceResult

  private

  def update_submission_with_best_score
    return unless @submission
    return if @submission.excused?
    return unless @current_score.present?

    if @current_score.to_f > @submission.score.to_f
      @submission.update_columns({ score: @current_score, grade: @current_grade, published_grade: @current_grade, published_score: @current_score })
    end
  end
end
