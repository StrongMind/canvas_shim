describe SettingsService do
  subject { described_class }

  describe '#get_settings' do
    it "uses default id if none is provided" do
      expect(SettingsService::Repository).to(
        receive(:put).with(hash_including(id: 1))
      )

      SettingsService.get_settings(object: :school)
    end
  end

  describe '#update_settings' do
    it 'calls the update setting command' do
      expect(
        SettingsService::Commands::UpdateSettings
      ).to receive(:new).with(
        id: 1,
        setting: "foo",
        value: "bar",
        object: 'assignment'
      ).and_return(double('command', call: nil))

      described_class.update_settings(
        id: 1,
        setting: 'foo',
        value: 'bar',
        object: 'assignment'
      )
    end
  end
end
