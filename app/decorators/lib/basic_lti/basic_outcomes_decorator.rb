BasicLTI::BasicOutcomes::LtiResponse.class_eval do
  attr_accessor :submission

  alias_method :homework_submission_alias, :create_homework_submission

  def create_homework_submission(_tool, submission_hash, assignment, user, new_score, raw_score)
    homework_submission_alias(_tool, submission_hash, assignment, user, new_score, raw_score)

    if SettingsService.get_settings(object: :school, id: 1)['lti_keep_highest_score']
      update_submission_with_best_score
    end
  end

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

    best_score = @submission.score
    best_grade = @submission.grade
    versions   = @submission.versions

    versions.each do |version|
      version_score = YAML.load(version.yaml).stringify_keys['score']
      if version_score.to_f > best_score.to_f
        best_score = version_score
        best_grade = YAML.load(version.yaml).stringify_keys['grade']
      end
    end

    @submission.update_columns({score: best_score, grade: best_grade, published_grade: best_grade, published_score: best_score})
  end
end
