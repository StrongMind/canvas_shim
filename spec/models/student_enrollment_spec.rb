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
    described_class.create(course: course, user: user)
  end

  before do
    allow(Time).to receive(:now).and_return(Time.now.utc)
  end

  describe "#days_since_active" do
     it "returns N/A when compared against a bad date" do
       expect(subject.days_since_active).to eq "N/A"
     end

     it "returns two days ago" do
       subject.update(last_activity_at: (3.days.ago - 1.hour))
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
       submission.update(submitted_at: (2.days.ago - 1.hour))
       expect(subject.days_since_last_submission).to eq 2
     end
  end
end