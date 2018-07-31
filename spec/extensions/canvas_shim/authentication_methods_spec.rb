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

  context 'method chaining' do
    before do
      controller.load_user
    end

    it 'calls the original method' do
      expect(controller.load_user_called?).to be(true)
    end

    it 'calls the new method' do
       expect(controller.canvas_shim_extensions).to eq ['load_user']
    end
  end
end
