describe SettingsService::Commands::UpdateEnrollmentSetting do
  before do
    SettingsService::Enrollment.canvas_domain = 'somedomain.com'
  end
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
        :table_name=>"somedomain.com-enrollment_settings",
        :id=>1,
        :setting=>"foo",
        :value=>"bar"
      )
      subject.call
    end
  end
end
