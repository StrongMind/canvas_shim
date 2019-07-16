describe "SubmissionMaxAttemptsDecorator" do
  let(:assignment) { Assignment.new }
  let(:submission) { Submission.new(score: 30, assignment: assignment) }
  let(:content_tag) { double "content_tag", context_module: context_module , id: assignment.id}
  let(:completion_requirements) {[requirement]}
  let(:context_module) { double "context_module", id: 10, completion_requirements: completion_requirements}
  let(:requirement) { {id: 10, min_score: 50 } }
  before do
    allow(ContentTag).to receive(:find_by).and_return(content_tag)
    allow(completion_requirements).to receive(:find).and_return(requirement)
  end

  describe '#send_max_attempts_alert' do
    let(:teacher) { double('teacher', id: 1) }
    let(:user) { double('user', id: 2) }
    let(:course) { double('course', id: 3) }


    it 'calls AlertsService::Client' do
      allow(assignment).to receive(:score).and_return(4)
      allow(assignment).to receive(:course).and_return(course)

      allow(submission).to receive(:student_locked?).and_return(true)
      allow(submission).to receive(:teachers_to_alert).and_return([teacher])
      allow(submission).to receive(:teacher).and_return([])
      allow(submission).to receive(:user).and_return(user)

      expect(AlertsService::Client).to receive(:create).with(
        :max_attempts_reached,
        teacher_id: teacher.id,
        student_id: user.id,
        assignment_id: assignment.id,
        course_id: course.id,
        score: 30
      )
      submission.send_max_attempts_alert
    end
  end

  describe "#student_locked?" do
    it "returns true if max_attempts reached and min_score not reached" do
      allow(submission).to receive(:max_attempts).and_return(3)
      allow(submission).to receive(:used_attempts).and_return(3)
      expect(submission.student_locked?).to eq(true)
    end

    it "returns false if max_attempts reached and score greater than min_score" do
      allow(submission).to receive(:max_attempts).and_return(3)
      allow(submission).to receive(:used_attempts).and_return(3)
      allow(submission).to receive(:score).and_return(60)
      expect(submission.student_locked?).to eq(false)
    end
  end
end
