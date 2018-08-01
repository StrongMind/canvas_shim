module AuthenticationMethods
  def load_user
    @current_user = User.new
  end
end
