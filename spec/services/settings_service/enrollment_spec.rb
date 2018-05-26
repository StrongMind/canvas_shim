describe SettingsService::Enrollment do
  subject { described_class.new }

  let(:table_name) {'testschool.strongmind.com-enrollment_settings'}

  before do
    ENV['CANVAS_DOMAIN'] = "testschool.strongmind.com"
  end
  it 'should exist' do
    expect {subject}.to_not raise_error
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

      subject.get(id: 1)
    end
  end

  describe '#put' do
    it 'calls put on the repository' do
      expect(SettingsService::Repository).to receive(:put).with(
          id: 1,
          setting: 'sequence_control',
          value: 'true',
          table_name: table_name
        )
      subject.put(id: 1, setting: 'sequence_control', value: 'true')
    end
  end

end
