puts 'original auth methods'
module AuthenticationMethods
  def load_user
    puts 'original load user'
  end
end

class Yaya;include AuthenticationMethods;end
