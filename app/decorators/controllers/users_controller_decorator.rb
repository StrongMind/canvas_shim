UsersController.class_eval do
  def strongmind_merge
    return unless can_do(@context, @current_user, :merge_users)
    instructure_merge
  end

  alias_method :instructure_merge, :merge
  alias_method :merge, :instructure_merge
end