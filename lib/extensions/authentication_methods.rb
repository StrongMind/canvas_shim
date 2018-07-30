puts 'wtf'
module AuthenticationMethods
  alias_method :original_load_user, :load_user
  def load_user
    puts 'WAAAAAT?'
    original_load_user

  end
end
#
# # class TestAM;include AuthenticationMethods;end
