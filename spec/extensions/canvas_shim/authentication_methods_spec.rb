class SomeRailsController
  include AuthenticationMethods
end

describe CanvasShim::AuthenticationMethods do
  subject { described_class }
  let(:controller) { SomeRailsController.new }

  describe '#load_user' do
    before do
      allow(HTTParty).to receive(:get).and_return(response)
    end

    context 'locked' do
      let(:response) { double('response', body: 'true') }
      it 'redirects if locked out' do
        expect(controller).to receive(:redirect_to)
        controller.load_user
      end
    end

    context 'not locked' do
      let(:response) { double('response', body: 'false') }
      it 'does not redirect if not locked out' do
        expect(controller).to_not receive(:redirect_to)
        controller.load_user
      end
    end
  end
end
