describe SettingsService::Commands::UpdateEnrollmentSetting do
  subject do
    SettingsService::Commands::UpdateEnrollmentSetting.new(
      id: 1,
      setting: 'foo',
      value: 'bar'
    )
  end

  describe '#call' do
    it 'saves the setting to the repository' do
      expect(SettingsService::Repository).to receive(:put).with(
        :table_name=>"-enrollment_settings",
        :id=>1,
        :setting=>"foo",
        :value=>"bar"

      )
      subject.call
    end
  end
end
