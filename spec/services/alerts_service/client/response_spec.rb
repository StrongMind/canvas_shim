describe AlertsService::Client::Response do
  let(:alert) { double(:alert) }
  subject { described_class.new(code: 200, payload: alert) }

  describe '#payload' do
    it do
      expect(subject.payload).to eq(alert)
    end
  end

  describe '#code' do
    it do
      expect(subject.code).to eq(200)
    end
  end
end