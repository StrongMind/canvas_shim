module Api::V1::Assignment
  def assignment_json(assignment, user, session, opts = {})
    {"id" => assignment.id}
  end
end