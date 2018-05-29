describe SettingsService::Enrollment do
  subject { described_class.new }

  let(:table_name) {'integration.example.com-enrollment_settings'}

  context '' do
    before do
      allow(SettingsService::Repository).to receive(:create_table)
      SettingsService::Repository.use_test_client!
    end

    it 'blows up if canvas domain is not present' do
      expect do
        subject.create_table
      end.to raise_error
    end
  end

  context 'canvas domain present' do
    before do
      ENV['CANVAS_DOMAIN'] = 'integration.example.com'
    end

    describe '#create_table' do
      it 'creates a table' do
        expect(SettingsService::Repository).to receive(:create_table)
          .with(name: table_name)
        subject.create_table
      end
    end

    describe '#get' do
      it 'fetches the settings for enrollment' do
        expect(SettingsService::Repository).to receive(:get).with(
          id: 1,
          table_name: table_name
        )

        described_class.get(id: 1)
      end
    end

    describe '#put' do
      it 'calls put on the repository' do
        expect(SettingsService::Repository).to receive(:put).with(
          id:         1,
          setting:    'sequence_control',
          value:      'true',
          table_name: table_name
        )
        subject.put(id: 1, setting: 'sequence_control', value: 'true')
      end
    end
  end

end
