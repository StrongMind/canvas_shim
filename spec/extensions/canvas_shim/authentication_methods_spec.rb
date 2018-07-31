module AuthenticationMethods
  def load_user
    puts 'lms applicaiton methods'
  end
end

class SomeRailsController
  include AuthenticationMethods
end

describe CanvasShim::AuthenticationMethods do
  subject { described_class }
  it 'works' do
    SomeRailsController.new.load_user
  end
end
