describe StudentEnrollment do
  include_context "stubbed_network"
  let!(:course) { Course.create }
  let!(:user) { User.create }
  let!(:assignment) { Assignment.create(course: course) }
  let!(:submission) do 
    Submission.create(
      assignment: assignment,
      user: user,
      context_code: "course_#{course.id}"
    )
  end

  subject do 
    described_class.create(course: course, user: user, scores: [Score.create])
  end

  before do
    allow(Time).to receive(:now).and_return(Time.now.utc)
  end

  describe "#days_since_active" do
     it "returns N/A when compared against a bad date" do
       expect(subject.days_since_active).to eq "N/A"
     end

     it "returns two days ago" do
       subject.update(last_activity_at: (3.days.ago))
       expect(subject.days_since_active).to eq 3
     end
  end

  describe "#days_since_last_submission" do
     it "returns N/A with no submission date" do
       expect(subject.days_since_last_submission).to eq "N/A"
     end

     it "returns N/A when compared against zerograded submissions" do
      submission.update(submitted_at: 2.days.ago, grader_id: 1)
      expect(subject.days_since_last_submission).to eq "N/A"
    end

     it "returns one day ago" do
       submission.update(submitted_at: (2.days.ago))
       expect(subject.days_since_last_submission).to eq 2
     end
  end

  describe "#missing_assignments_count" do
    context "deleted assignment" do
      let!(:assignment) { Assignment.create(course: course, workflow_state: "deleted") }

      let!(:submission) do
        Submission.create(
          assignment: assignment,
          user: user,
          context_code: "course_#{course.id}",
          cached_due_date: 1.day.ago,
          workflow_state: "unsubmitted"
        )
      end

      it "counts as 0" do
        expect(subject.missing_assignments_count).to eq(0)
      end
    end

    context "unpublished assignment" do
      let!(:assignment) { Assignment.create(course: course, workflow_state: "unpublished") }

      let!(:submission) do
        Submission.create(
          assignment: assignment,
          user: user,
          context_code: "course_#{course.id}",
          cached_due_date: 1.day.ago,
          workflow_state: "unsubmitted"
        )
      end

      it "counts as 0" do
        expect(subject.missing_assignments_count).to eq(0)
      end
    end

    context "past due and unsubmitted" do
      let!(:assignment) { Assignment.create(course: course, workflow_state: "published") }

      let!(:submission) do 
        Submission.create(
          assignment: assignment,
          user: user,
          context_code: "course_#{course.id}",
          cached_due_date: 1.day.ago,
          workflow_state: "unsubmitted"
        )
      end

      it "counts as 1" do
        expect(subject.missing_assignments_count).to eq(1)
      end
    end

    context "Zero graded" do
      let!(:assignment) { Assignment.create(course: course, workflow_state: "published") }

      let!(:submission) do 
        Submission.create(
          assignment: assignment,
          user: user,
          context_code: "course_#{course.id}",
          cached_due_date: 1.day.ago,
          workflow_state: "submitted",
          grader_id: 1
        )
      end

      it "counts as 1" do
        expect(subject.missing_assignments_count).to eq(1)
      end
    end
  end

  describe "#strongmind_final_score_recalculation" do
    it "will not run when workflow state is not completed" do
      expect(StudentEnrollment).not_to receive(:send_later)
      subject.update(workflow_state: "active")
    end

    it "will run when workflow_state is completed" do
      expect(StudentEnrollment).to receive(:send_later).with(
        :recompute_final_score, user.id, course.id
      )
      subject.update(workflow_state: "completed")
    end

    context "scores-related callback" do
      it "will not update if score is present" do
        expect(StudentEnrollment).not_to receive(:send_later).with(
          :recompute_final_score, user.id, course.id
        )
        subject.save
      end

      it "will not update if score is present" do
        subject.update(scores: [])
        expect(StudentEnrollment).to receive(:send_later).with(
          :recompute_final_score, user.id, course.id
        )
        subject.save
      end
    end
  end
end