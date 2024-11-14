describe BasicLTI::BasicOutcomes::LtiResponse do
  subject { described_class.new }

  describe '#create_homework_submission' do
    let(:tool_id) { Faker::Number.number(10) }
    let(:submission_hash) { Faker::Number.number(10) }
    let(:assignment) { Assignment.first }
    let(:submission) { Submission.first }
    let(:user) { User.create }
    let(:score) { Faker::Number.between(0, 100) }
    let(:new_score) { score }
    let(:raw_score) { score }

    context 'featured' do


      let(:version) { SubmissionVersion.create(yaml: { score: 100, grade: 100, excused: false }.to_yaml) }
      let(:version2) { SubmissionVersion.create(yaml: { score: 90, grade: 90, excused: false }.to_yaml) }
      let(:version3) { SubmissionVersion.create(yaml: { score: 80, grade: 80, excused: false }.to_yaml) }

      before do
        allow(PipelineService).to receive(:publish)
        allow(SettingsService).to receive(:get_settings).and_return('lti_keep_highest_score' => true)
      end

      it 'should call the shimmed method' do
        expect(subject).to receive(:update_submission_with_best_score)
        subject.create_homework_submission(tool_id, submission_hash, assignment, user, new_score, raw_score)
      end

      context "when there are no previous submissions" do
        it 'wont update' do
          expect(submission).to_not receive(:update)
          subject.create_homework_submission(tool_id, submission_hash, assignment, user, new_score, raw_score)
        end

        it 'has the saved score' do
          subject.create_homework_submission(tool_id, submission_hash, assignment, user, new_score, raw_score)
          expect(Submission.last.score).to eq(score)
        end
      end

      context 'when there is a previous submission' do
        let(:higher_score) { Faker::Number.between(51, 100) }
        let(:lower_score) { Faker::Number.between(0, 50) }

        before do
          subject.instance_variable_set('@submission', submission)
        end

        context 'when the previous submission score is higher than the new score' do
          it 'updates the submission score with the previous submission score' do
            user
            submission.update!(assignment_id: assignment.id,
                                     user_id: user.id,
                                     score: higher_score,
                                     grade: higher_score)

            subject.create_homework_submission(tool_id, submission_hash, assignment, user, lower_score, lower_score)
            expect(submission.score).to eq(higher_score)
          end
        end

        context 'when the previous submission score is lower than the new score' do
          it 'does not update the submission score' do
            user
            submission.update!(assignment_id: assignment.id,
                                     user_id: user.id,
                                     score: lower_score,
                                     grade: lower_score)

            subject.create_homework_submission(tool_id, submission_hash, assignment, user, higher_score, higher_score)
            expect(submission.score).to eq(higher_score)
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
        subject.create_homework_submission(tool_id, submission_hash, assignment, user, new_score, raw_score)
      end
    end

    context 'excused submission' do
      before do
        allow(SettingsService).to receive(:get_settings).and_return('lti_keep_highest_score' => true)
      end
      let(:submission) do
        Submission.create(excused: true, assignment: assignment)
      end
      it 'will not update' do
        expect(submission).to_not receive(:update)
        subject.create_homework_submission(tool_id, submission_hash, assignment, user, new_score, raw_score)
      end
    end

  end
end
