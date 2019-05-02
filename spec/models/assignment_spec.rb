describe Assignment do
  include_context "stubbed_network"
  let(:assignment) { Assignment.create }
  let(:user) { User.create }
  let(:submission) { Submission.create(assignment: assignment, user: user, excused: nil) }
  let(:user_2) { User.create }

  describe "#toggle_exclusion" do
    it "flips the excused status" do
      submission
      assignment.toggle_exclusion(user.id)
      submission = assignment.submissions.find_by(user_id: user.id)
      expect(submission.excused).to be true
      assignment.toggle_exclusion(user.id)
      submission = assignment.submissions.find_by(user_id: user.id)
      expect(submission.excused).to be false
    end

    it "returns nil if no user found" do
      expect(assignment.toggle_exclusion(user_2.id)).to be nil
    end
  end
end