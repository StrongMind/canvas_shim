describe BasicLTI::BasicOutcomes::LtiResponse do
  subject { described_class.new }

  describe '#create_homework_submission' do
    let(:tool_id) { Faker::Number.number(10) }
    let(:submission_hash) { Faker::Number.number(10) }
    let!(:assignment) { Assignment.create!(assignment_group: AssignmentGroup.create) }
    let(:user) { User.create }
    let(:score) { Faker::Number.between(0, 100) }
    let(:new_score) { score }
    let(:raw_score) { score }

    context 'featured' do
      let(:submission) do
        Submission.create(excused: false,
                          versions: [version, version2, version3],
                          score: score,
                          grade: score,
                          assignment: assignment)
      end

      let(:version) { SubmissionVersion.create(yaml: { score: 100, grade: 100, excused: false }.to_yaml) }
      let(:version2) { SubmissionVersion.create(yaml: { score: 90, grade: 90, excused: false }.to_yaml) }
      let(:version3) { SubmissionVersion.create(yaml: { score: 80, grade: 80, excused: false }.to_yaml) }



      before do
        assignment
        allow(PipelineService).to receive(:publish)
        allow(SettingsService).to receive(:get_settings).and_return('lti_keep_highest_score' => true)
        submission.assignment_id = assignment.id
        submission.save!
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

        context 'when the previous submission score is higher than the new score' do
          let!(:submission) do
            Submission.create(excused: false, versions: [version, version2, version3], score: higher_score, grade: higher_score)
          end

          it 'updates the submission score with the previous submission score' do
            user
            Submission.first.update!(assignment_id: Assignment.first.id,
                                     user_id: User.first.id,
                                     score: higher_score,
                                     grade: higher_score)

            subject.instance_variable_set('@submission', Submission.first)
            subject.create_homework_submission(tool_id, submission_hash, Assignment.first, User.first, lower_score, lower_score)
            expect(Submission.last.score).to eq(higher_score)
          end
        end

        context 'when the previous submission score is lower than the new score' do
          let!(:submission) do
            Submission.create!(excused: false,
                               versions: [version, version2, version3],
                               score: lower_score,
                               grade: lower_score,
                               user: user,
                               assignment: assignment)
          end

          before do
            assignment
            submission
          end

          it 'does not update the submission score' do
            subject.create_homework_submission(tool_id, submission_hash, assignment, user, higher_score, higher_score)
            expect(Submission.last.score).to eq(higher_score)
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
      it 'wont update' do
        expect(submission).to_not receive(:update)
        subject.create_homework_submission(tool_id, submission_hash, assignment, user, new_score, raw_score)
      end
    end

  end
end
