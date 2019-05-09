describe Assignment do
  include_context "stubbed_network"
  let(:assignment) { Assignment.create }
  let(:user) { User.create }
  let(:submission) { Submission.create(assignment: assignment, user: user, excused: nil) }
  let(:user_2) { User.create }

  describe "#toggle_exclusion" do
    it "flips the excused status to true" do
      submission
      assignment.toggle_exclusion(user.id, true)
      submission = assignment.submissions.find_by(user_id: user.id)
      expect(submission.excused).to be true
    end

    it "flips the excused status to false" do
      submission
      assignment.toggle_exclusion(user.id, false)
      submission = assignment.submissions.find_by(user_id: user.id)
      expect(submission.excused).to be false
    end

    it "returns nil if no user found" do
      expect(assignment.toggle_exclusion(user_2.id, true)).to be nil
    end
  end

  describe "#is_excused?" do
    it "returns true when excused" do
      submission.update(excused: true)
      expect(assignment.is_excused?(user)).to be true
    end

    it "returns false when unexcused" do
      submission
      expect(assignment.is_excused?(user)).to be false
    end
  end
end