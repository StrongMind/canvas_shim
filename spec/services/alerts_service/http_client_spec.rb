describe AlertsService::HTTPClient do
  subject { described_class }
  let(:alert) { double('alert', as_json: {}) }
  
  describe '#post' do
    it do
      VCR.use_cassette 'alerts_service/http_client/post' do
        subject.post(alert)
      end
    end
  end

  describe '#get' do
  end

  describe '#list' do
  end

  describe '#destroy' do
  end
end