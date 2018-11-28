describe BasicLTI::BasicOutcomes::LtiResponse do
  subject { described_class.new }
  describe '#create_homework_submission' do
    context "featured" do
      before do
        allow(SettingsService).to receive(:get_settings).and_return('lti_keep_highest_score' => true)
      end
    end

    it do
      subject.create_homework_submission(1,2,3,4,5,6)
    end
  end
end
