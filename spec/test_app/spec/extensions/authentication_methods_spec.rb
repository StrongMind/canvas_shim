describe 'something' do
  class MockClass
    include AuthenticationMethods
  end

  let(:instance) { MockClass.new }

  before do
    allow(instance).to receive(:redirect_to)
    allow(MockClass).to receive(:new).and_return(instance)
    allow(HTTParty).to receive(:get).and_return(response)
  end

  describe '#load_user' do
    context 'not locked' do
      let(:response) { double(:response, body: 'false') }

      it 'does not redirect' do
        expect(instance).to_not receive(:redirect_to)
        MockClass.new.load_user
      end
    end

    context 'locked' do
      let(:response) { double(:response, body: 'true') }

      it 'redirects' do
        expect(instance).to receive(:redirect_to)
        MockClass.new.load_user
      end
    end
  end
end
