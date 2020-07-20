describe SettingsService::School do
  subject {
    described_class.new
  }

  let(:table_name) { 'integration.example.com-school_settings' }

  before do
    SettingsService.settings_table_prefix = 'integration.example.com'
    Rails.cache.delete(:table_name)
  end

  describe '#create_table' do
    it 'creates a table' do
      expect(SettingsService::Repository).to receive(:create_table)
        .with(name: table_name)

      described_class.create_table
    end
  end

  describe '#get' do
    it 'fetches the settings for school' do
      expect(SettingsService::Repository).to receive(:get).with(
        id: 1,
        table_name: table_name
      )

      described_class.get(id: 1)
    end

    it 'returns cached results' do
      allow(Rails.cache).to receive(:read).and_return({bob: "bob", saget: true})
      expect(described_class.get(id: 1)).to eq({:bob => "bob", :saget => true})
    end
  end
end
