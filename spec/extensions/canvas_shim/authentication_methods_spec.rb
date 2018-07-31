module AuthenticationMethods
  def load_user_called?
    @original_method_called
  end

  def load_user
    @original_method_called = true
  end
end

class SomeRailsController
  include AuthenticationMethods
end

describe CanvasShim::AuthenticationMethods do
  subject { described_class }
  let(:controller) { SomeRailsController.new }


  before do

  end

  it 'works' do
    controller.load_user
    expect(controller.load_user_called?).to be(true)
    expect(controller.canvas_shim_extensions).to eq ['load_user']
  end
end
