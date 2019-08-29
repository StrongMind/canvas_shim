describe "SubmissionExcusedGuardDecorator" do
  include_context 'stubbed_network'
  let!(:submission) { Submission.create(score: 30, assignment: assignment, excused: true) }
  let!(:submission2) { Submission.create(score: 30, assignment: assignment, excused: true) }

  let(:assignment) { Assignment.new }


  describe "When a submission is excused" do

    it "does not record a score" do
      submission.update(score: 55)
      expect(submission.score).to eq(30)
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
      submission.update(excused: false)
      expect(submission.submission_comments.first.comment).to eq("This assignment is no longer excused.")
    end

    it "does not record a comment when the excused tag is not removed" do
      submission.update(score: 55, grader_id: 5)
      expect(submission2.submission_comments).to eq([])
    end

  end
end
