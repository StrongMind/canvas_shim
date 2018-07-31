Dir["#{Rails.root}/lib/extensions/*.rb"].each { |file| require file }

module YAYA
  def load_user
    puts 'WAAAAAT?'
    original_load_user
  end
end


module AuthenticationMethodsShim
  include YAYA
  def self.included base
    base.send :alias_method, :original_load_user, :load_user
    base.send :define_method, YAYA.instance_method(:load_user)
  end
end



AuthenticationMethods.include AuthenticationMethodsShim
class TestAM;include AuthenticationMethods;end
