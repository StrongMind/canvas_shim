describe 'AuthenticationMethods extension' do
  subject do
    class MockClass;include AuthenticationMethods;end.new
  end

  before do
    allow(HTTParty).to receive(:get).and_return(response)
  end

  describe '#load_user' do
    let(:response) { double(:response, body: 'true') }

    it 'redirects if the studnet is locked out' do
      expect(subject).to receive(:redirect_to)
      subject.load_user
    end
  end
end
