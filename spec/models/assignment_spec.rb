describe Assignment do
  include_context "stubbed_network"
  let(:assignment) { create(:assignment, :with_assignment_group)}
  let(:user) { User.create }
  let(:submission) { Submission.create(assignment: assignment, user: user, excused: nil, score: 50, grade: 1) }
  let(:user_2) { User.create }

  describe "#toggle_exclusion" do
    it "sets submission excused to true if is_excused" do
      submission
      assignment.toggle_exclusion(user.id, true)
      submission = assignment.submissions.find_by(user_id: user.id)
      expect(submission.excused).to be true
    end

    it "sets submission score to be nil if is_excused" do
      submission
      assignment.toggle_exclusion(user.id, true)
      submission = assignment.submissions.find_by(user_id: user.id)
      expect(submission.score).to be nil
    end

    it "sets submission grade to be nil if is_excused" do
      submission
      assignment.toggle_exclusion(user.id, true)
      submission = assignment.submissions.find_by(user_id: user.id)
      expect(submission.grade).to be nil
    end

    it "sets submission excused to false if is_excused is false" do
      submission
      assignment.toggle_exclusion(user.id, false)
      submission = assignment.submissions.find_by(user_id: user.id)
      expect(submission.excused).to be false
    end

    it "does not change submission score if is_excused is false" do
      submission
      assignment.toggle_exclusion(user.id, false)
      submission = assignment.submissions.find_by(user_id: user.id)
      expect(submission.score).to be 50
    end

    it "does not change submission grade to be nil if is_excused is true" do
      submission
      assignment.toggle_exclusion(user.id, false)
      submission = assignment.submissions.find_by(user_id: user.id)
      expect(submission.grade).to be 1
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

  describe "when saved" do
    it "publishes to pipeline" do
      expect(PipelineService).to receive(:publish_as_v2)
      create(:assignment, :with_assignment_group) 
    end
  end
end
