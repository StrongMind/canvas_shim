describe Submission do
  context 'callbacks' do
    before do
      allow(PipelineService).to receive(:publish)
      allow(PipelineService::V2).to receive(:publish)
    end

    context "V2 Submissions" do
      describe '#send_submission_to_pipeline' do
        before do
          allow(SettingsService).to receive(:get_settings).and_return({
              'enable_unit_grade_calculations' => false,
              'v2_submissions' => true
            })
        end

        it 'publishes on create' do
          expect(PipelineService::V2).to receive(:publish).with an_instance_of(Submission)
          Submission.create
        end

        it 'publishes on save' do
          s = Submission.create
          expect(PipelineService::V2).to receive(:publish).with an_instance_of(Submission)
          s.save
        end

        it 'doesnt post to the v1 client' do
          s = Submission.create
          expect(PipelineService::HTTPClient).not_to receive(:post)
          s.save
        end

      end
    end
  end

  context "Message callbacks" do
    include_context 'stubbed_network'
    before do
      allow(SettingsService).to receive(:update_settings).and_return({})
      allow(course).to receive(:teacher_enrollments).and_return([teacher])
    end

    let!(:course) { Course.create }
    let!(:user) { User.create }
    let!(:assignment) { Assignment.create(course: course) }
    let!(:enrollment) { Enrollment.create(user: user, course: course) }
    let!(:teacher) { Enrollment.create(user: User.create, course: course, type: "TeacherEnrollment") }
    let!(:submission) { Submission.create(user: user, score: 30, assignment: assignment, excused: true) }
    let!(:submission2) { Submission.create(user: user, score: 30, assignment: assignment, excused: true) }


    it "records a comment when the excused tag is removed" do
      submission.update(excused: false)
      expect(submission.submission_comments.first.comment).to eq(Submission.new.send(:unexcused_comment))
    end

    it "does not record a comment when the excused tag is not removed" do
      submission.update(score: 55, grader_id: 5)
      expect(submission2.submission_comments).to eq([])
    end
  end
end
