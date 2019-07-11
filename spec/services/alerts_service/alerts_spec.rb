describe AlertsService::Alerts do
  let(:alert_fields) { { alert: {techer_id: 1, type: 'max_attempts_reached'} } }
  
  describe '#list_from_json' do
    let(:json) { [alert_fields].to_json }
    
    it do
      expect(described_class.list_from_json(json).first).to be_a(AlertsService::Alerts::MaxAttemptsReached)
    end
  end
  
  describe '#from_json' do
    let(:json) { alert_fields.to_json }
    
    it do
      expect(described_class.from_json(json)).to be_a(AlertsService::Alerts::MaxAttemptsReached)
    end
  end
end