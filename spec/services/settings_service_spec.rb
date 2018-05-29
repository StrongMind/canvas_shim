describe SettingsService do
  subject { described_class }

  describe '#get_enrollment_settings' do
    it 'calls the update setting command' do
      expect(
        SettingsService::Commands::GetEnrollmentSettings
      ).to receive(:new).with(:id=>1,).and_return(double('command', call: nil))

      described_class.get_enrollment_settings(id: 1)
    end
  end

  describe '#update_enrollment_setting' do
    it 'calls the get settings command' do
      expect(
        SettingsService::Commands::UpdateEnrollmentSetting
      ).to receive(:new).with(
        :id=>1,
        :setting=>"foo",
        :value=>"bar"
      ).and_return(double('command', call: nil))

      described_class.update_enrollment_setting(
        id: 1,
        setting: 'foo',
        value: 'bar'
      )
    end
  end
end
