describe BasicLTI::BasicOutcomes::LtiResponse do
  subject { described_class.new }
  describe '#create_homework_submission' do
    context 'featured' do
      let(:submission) do
        Submission.create(excused: false, versions: [version, version2, version3], score: 100, grade: 100)
      end

      let(:version) { SubmissionVersion.create(yaml: { score: 100, grade: 100, excused: false }.to_yaml) }
      let(:version2) { SubmissionVersion.create(yaml: { score: 90, grade: 90, excused: false }.to_yaml) }
      let(:version3) { SubmissionVersion.create(yaml: { score: 80, grade: 80, excused: false }.to_yaml) }

      let(:tool_id) { Faker::Number.number(digits: 10) }
      let(:submission_hash) { Faker::Number.number(digits: 10) }
      let(:assignment) { Faker::Number.number(digits: 10) }
      let(:user) { Faker::Number.number(digits: 10) }
      let(:score) { Faker::Number.between(from: 0, to: 100) }
      let(:new_score) { score }
      let(:raw_score) { score }

      before do
        allow(PipelineService).to receive(:publish)
        allow(SettingsService).to receive(:get_settings).and_return('lti_keep_highest_score' => true)
        subject.instance_variable_set('@submission', submission)
      end

      it 'should call the shimmed method' do
        expect(subject).to receive(:update_submission_with_best_score)
        subject.create_homework_submission(1, 2, 3, 4, 5, 6)
      end

      it 'sets the score and grade to the highest in the submission history' do
        expect(submission).to receive(:update_columns).with({ grade: 100, score: 100, published_grade: 100, published_score: 100 })
        subject.create_homework_submission(1, 2, 3, 4, 5, 6)
      end

      context "when there are no previous submissions" do


        before do
          subject.instance_variable_set('@submission', nil)
        end

        it 'wont update' do
          expect(submission).to_not receive(:update)
          subject.create_homework_submission(tool_id, submission_hash, assignment, user, new_score, raw_score)
        end

        it 'has the saved score' do
          subject.create_homework_submission(tool_id, submission_hash, assignment, user, new_score, raw_score)
          expect(submission.reload.score).to eq(score)
        end
      end

      context 'when there is a previous submission' do
        let(:higher_score) { Faker::Number.between(from: 51, to: 100) }
        let(:lower_score) { Faker::Number.between(from: 0, to: 50) }

        context 'when the previous submission score is higher than the new score' do
          let(:submission) do
            Submission.create(excused: false, versions: [version, version2, version3], score: higher_score, grade: higher_score)
          end

          it 'updates the submission score with the previous submission score' do
            subject.create_homework_submission(tool_id, submission_hash, assignment, user, lower_score, lower_score)
            expect(submission.reload.score).to eq(higher_score)
          end
        end

        context 'when the previous submission score is lower than the new score' do
          let(:submission) do
            Submission.create(excused: false, versions: [version, version2, version3], score: lower_score, grade: lower_score)
          end

          it 'does not update the submission score' do
            subject.create_homework_submission(tool_id, submission_hash, assignment, user, higher_score, higher_score)
            expect(submission.reload.score).to eq(higher_score)
          end
        end
      end

    end

    context 'unfeatured' do
      before do
        allow(SettingsService).to receive(:get_settings).and_return('lti_keep_highest_score' => false)
      end

      it 'should not call the shimmed method' do
        expect(subject).to_not receive(:update_submission_with_best_score)
        subject.create_homework_submission(1, 2, 3, 4, 5, 6)
      end
    end

    context 'excused submission' do
      before do
        allow(SettingsService).to receive(:get_settings).and_return('lti_keep_highest_score' => true)
      end
      let(:submission) do
        Submission.create(excused: true)
      end
      it 'wont update' do
        expect(submission).to_not receive(:update)
        subject.create_homework_submission(1, 2, 3, 4, 5, 6)
      end
    end

  end
end
