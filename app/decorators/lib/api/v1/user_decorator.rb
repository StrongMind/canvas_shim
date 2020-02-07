Api::V1::User.class_eval do

  def strongmind_user_json(user, current_user, session, includes = [], context = @context, enrollments = nil, excludes = [])
    json = instructure_user_json(user, current_user, session, includes, context, enrollments, excludes)
    json[:is_online] = user.is_online?
    json
  end

  alias_method :instructure_user_json, :user_json
  alias_method :user_json, :strongmind_user_json
  
end