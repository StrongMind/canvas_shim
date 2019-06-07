describe AlertsService::HTTPClient do
  subject { described_class }
  let(:alert) { double('alert', as_json: {}) }
  
  describe '#post' do
    it do
      subject.post(alert)
    end
  end

  describe '#get' do
  end

  describe '#list' do
  end

  describe '#destroy' do
  end
end