Pseudonym.class_eval do
  after_save :do_something, if: :last_login_at_changed?

  def do_something
    if Current.current_user != Current.logged_in_user
      binding.pry
      restore_attributes([:current_login_at, :last_login_at])
      binding.pry
    end
  end
end
