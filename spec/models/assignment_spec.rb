describe Assignment do
  include_context "stubbed_network"
  let(:assignment) { Assignment.create }
  let(:user) { User.create }
  let(:submission) { Submission.create(assignment: assignment, user: user, excused: nil) }
  let(:user_2) { User.create }

  describe "#exclude_student" do
    it "flips the excused status" do
      submission
      assignment.exclude_student(user.id)
      submission = assignment.submissions.find_by(user_id: user.id)
      expect(submission.excused).to be true
      assignment.exclude_student(user.id)
      submission = assignment.submissions.find_by(user_id: user.id)
      expect(submission.excused).to be false
    end

    it "returns nil if no user found" do
      expect(assignment.exclude_student(user_2.id)).to be nil
    end
  end
end