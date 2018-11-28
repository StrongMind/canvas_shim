describe BasicLTI::BasicOutcomes::LtiResponse do
  subject { described_class.new }
  describe '#create_homework_submission' do
    context 'featured' do
      let(:submission) do
        Submission.create(versions: [version, version2, version3], score: 10, grade: 10)
      end

      let(:version) { SubmissionVersion.create(yaml: {score: 100, grade: 100}.to_yaml) }
      let(:version2) { SubmissionVersion.create(yaml: {score: 90, grade: 90}.to_yaml) }
      let(:version3) { SubmissionVersion.create(yaml: {score: 80, grade: 80}.to_yaml) }

      before do
        allow(SettingsService).to receive(:get_settings).and_return('lti_keep_highest_score' => true)
        subject.instance_variable_set('@submission', submission)
      end

      it 'should call the shimed method' do
        expect(subject).to receive(:update_subission_with_best_score)
        subject.create_homework_submission(1,2,3,4,5,6)
      end

      it 'sets the score and grade to the highest in the submission history' do
        expect(submission).to receive(:update).with(grade: 100, score: 100)
        subject.create_homework_submission(1,2,3,4,5,6)
      end

      context "no submission" do
        before do
          subject.instance_variable_set('@submission', nil)
        end

        it 'wont update' do
          expect(submission).to_not receive(:update)
          subject.create_homework_submission(1,2,3,4,5,6)
        end
      end
    end

    context 'unfeatured' do
      before do
        allow(SettingsService).to receive(:get_settings).and_return('lti_keep_highest_score' => false)
      end

      it 'should not call the shimed method' do
        expect(subject).to_not receive(:update_subission_with_best_score)
        subject.create_homework_submission(1,2,3,4,5,6)
      end
    end
  end
end
