describe AlertsService::Client do
  subject { described_class }

  let(:alert) { double('alert') }
  let(:http_client) { double('http_client', post: nil) }

  describe '#get'
  describe '#list'
  describe '#create' do
    it do
      expect(subject.instance).to receive(:http_client).and_return(http_client)
      subject.create(alert)
    end
  end
  describe '#destroy'
end