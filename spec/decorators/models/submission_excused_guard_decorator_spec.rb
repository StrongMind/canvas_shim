describe "SubmissionExcusedGuardDecorator" do
  include_context 'stubbed_network'
  let!(:submission) { Submission.create(score: 30) }
  let(:assignment) { Assignment.new }

  context "submission excused" do
    before do
      submission.update(excused: true)
    end

    describe "When a submission is excused" do
      it "does not record a score" do
        submission.update(score: 55, grader_id: -1)
        expect(submission.reload.score).to eq(30)
      end

      it "does record a score if the grader id is a positive integer(Not LTI/Autograded)" do
        submission.update(score: 55, grader_id: 5)
        expect(submission.score).to eq(55)
      end

      it "does record a score if the grader id is a positive integer(Not LTI/Autograded)" do
        submission.update(score: 55, grader_id: 5)
        expect(submission.score).to eq(55)
        expect(submission.excused).to eq(true)
      end

      it "records a comment when the excused tag is removed" do
        allow(submission).to receive(:changes).and_return({excused: [true, false]})
        submission.update(excused: false, grader_id: 5)
        expect(submission.submission_comments.first.comment).to eq("This assignment is no longer excused.")
      end

      it "does not record a comment when the excused tag is not removed" do
        submission.update(score: 55, grader_id: 5)
        expect(submission.submission_comments).to eq([])
      end
    end
  end
end
