describe RequirementsService::Commands::SetThresholdPermissions do
  include_context 'stubbed_network'
  context "Happy path" do
    subject do 
      described_class.new(
        course_thresholds: true,
        post_enrollment: true,
        module_editing: true
      )
    end

    describe "#call" do
      let(:settings) do
        {
          object: 'school',
          id: 1,
          value: true
        }
      end
      it "sets the correct settings" do
        expect(SettingsService).to receive(:update_settings).with(
          settings.merge(setting: 'course_threshold_enabled')
        )
        expect(SettingsService).to receive(:update_settings).with(
          settings.merge(setting: 'enable_post_enrollment_threshold_updates')
        )
        expect(SettingsService).to receive(:update_settings).with(
          settings.merge(setting: 'disable_module_editing')
        )
        subject.call
      end
    end
  end
end