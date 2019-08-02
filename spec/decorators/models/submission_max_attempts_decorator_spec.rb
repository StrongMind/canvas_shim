describe "SubmissionMaxAttemptsDecorator" do
  let(:assignment) { Assignment.new }
  let(:submission) { Submission.new(score: 30, assignment: assignment, versions: versions) }
  let(:content_tag) { double "content_tag", context_module: context_module , id: assignment.id}
  let(:completion_requirements) {[requirement]}
  let(:context_module) { double "context_module", id: 10, completion_requirements: completion_requirements}
  let(:requirement) { {id: 10, min_score: 50 } }
  let(:versions) { [] }

  before do
    allow(ContentTag).to receive(:find_by).and_return(content_tag)
    allow(completion_requirements).to receive(:find).and_return(requirement)
  end

  describe '#best_score' do
    let(:versions) do
      [
        SubmissionVersion.new(yaml: {score: 50, grade: 50}.to_yaml),
        SubmissionVersion.new(yaml: {score: 10, grade: 10}.to_yaml),
        SubmissionVersion.new(yaml: {score: 39, grade: 39}.to_yaml)
      ]
    end

    it 'returns the best score in versions' do
      expect(submission.best_score).to eq 50
    end

    context 'no versions' do
      let(:versions) {[]}
      it 'returns the submission#score' do
        expect(submission.best_score).to eq 30
      end
    end
  end

  describe '#send_max_attempts_callback' do
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
        :max_attempts_reached_min_score,
        teacher_id: teacher.id,
        student_id: user.id,
        assignment_id: assignment.id,
        course_id: course.id,
        score: 30
      )
      submission.send_max_attempts_callback
    end
  end

  describe "#student_locked?" do
    it "does not error is score is nil" do
      allow(submission).to receive(:used_attempts).and_return(3)
      allow(submission).to receive(:max_attempts).and_return(3)
      allow(submission).to receive(:score).and_return(nil)
      expect(submission.student_locked?).to eq(true)
    end

    it "does not error is best score is nil" do
      allow(submission).to receive(:used_attempts).and_return(3)
      allow(submission).to receive(:max_attempts).and_return(3)
      allow(submission).to receive(:score).and_return(nil)
      allow(submission).to receive(:score).and_return(nil)
      allow(submission).to receive(:best_score).and_return(nil)
      expect(submission.student_locked?).to eq(true)
    end


    it "returns true if max_attempts reached and min_score not reached" do
      allow(submission).to receive(:max_attempts).and_return(3)
      allow(submission).to receive(:used_attempts).and_return(3)
      expect(submission.student_locked?).to eq(true)
    end

    it "returns false if max_attempts reached and score greater than min_score" do
      allow(submission).to receive(:max_attempts).and_return(3)
      allow(submission).to receive(:used_attempts).and_return(3)
      allow(submission).to receive(:score).and_return(60)
      expect(submission.student_locked?).to be_nil
    end

    it "returns false if best score is higher than threshold" do
      allow(submission).to receive(:max_attempts).and_return(3)
      allow(submission).to receive(:used_attempts).and_return(3)
      allow(submission).to receive(:score).and_return(10)
      allow(submission).to receive(:best_score).and_return(55)
      expect(submission.student_locked?).to be_nil
    end


    describe "#send_max_attempts_alert?" do
      it "if false if used attempts is greater than max_attempts" do
        allow(submission).to receive(:max_attempts).and_return(3)
        allow(submission).to receive(:used_attempts).and_return(4)
        expect(submission.send_max_attempts_alert?).to eq(false)
      end

      it "is false if used attempts is less than max_attempts" do
        allow(submission).to receive(:max_attempts).and_return(3)
        allow(submission).to receive(:used_attempts).and_return(2)
        expect(submission.send_max_attempts_alert?).to eq(false)
      end

      it "is true if used attempts is equal to max_attempts" do
        allow(submission).to receive(:max_attempts).and_return(3)
        allow(submission).to receive(:used_attempts).and_return(3)
        expect(submission.send_max_attempts_alert?).to eq(true)
      end

    end

  end
end
