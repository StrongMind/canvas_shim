module Api::V1::Submission
  def strongmind_submission_json submission, assignment, user, session, context=nil, includes=[], timestamps=nil
    instructure_json = instructure_submission_json
    return instructure_json unless timestamps
    instructure_json.merge(created_at: submission.created_at, updated_at: stubmission.updated_at)
  end

  alias_method :instructure_submission_json, :submission_json
  alias_method :submission_json, :strongmind_submission_json
end