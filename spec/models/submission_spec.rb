describe Submission do
  include_context 'stubbed_network'
  context 'callbacks' do
    before do
      allow(PipelineService).to receive(:publish)
      allow(PipelineService::V2).to receive(:publish)
    end

    context "V2 Submissions" do
      let(:assignment) { Assignment.create }

      describe '#send_submission_to_pipeline' do
        before do
          allow(SettingsService).to receive(:get_settings).and_return({
              'enable_unit_grade_calculations' => false,
              'v2_submissions' => true
            })
        end

        it 'publishes on create' do
          expect(PipelineService::V2).to receive(:publish).with an_instance_of(Submission)
          expect(PipelineService::V2).to receive(:publish).with an_instance_of(Assignment)
          Submission.create(assignment: assignment)
        end

        it 'publishes on save' do
          s = Submission.create(assignment: assignment)
          expect(PipelineService::V2).to receive(:publish).with an_instance_of(Submission)
          expect(PipelineService::V2).to receive(:publish).with an_instance_of(Assignment)
          s.save
        end

        it 'doesnt post to the v1 client' do
          s = Submission.create(assignment: assignment)
          expect(PipelineService::HTTPClient).not_to receive(:post)
          s.save
        end

      end
    end
  end

  context "Message callbacks" do
    include_context 'stubbed_network'
    let!(:submission) { Submission.create(score: 30, assignment: assignment, excused: true) }
    let!(:submission2) { Submission.create(score: 30, assignment: assignment, excused: true) }

    let(:assignment) { Assignment.new }
    let(:teacher) { User.create }

    it "records a comment when the excused tag is removed" do
      submission.update(excused: false, grader_id: teacher.id)
      expect(submission.submission_comments.first.comment).to eq(Submission.new.send(:unexcused_comment))
    end

    it "does not record a comment when the excused tag is not removed" do
      submission.update(score: 55, grader_id: teacher.id)
      expect(submission2.submission_comments).to eq([])
    end
  end

context "Submission Needs Regrading" do
    let!(:student) { User.create() }
    let!(:submission) { Submission.create(score: 0, grader_id: 1, submitted_at: 1.hour.ago, assignment: assignment, user: student, excused: false )}

    let!(:course) { Course.create() }
    let!(:teacher_enrollment) { TeacherEnrollment.create(course: course, user: teacher) }
    let!(:assignment) { Assignment.new(course: course) }
    let!(:teacher) { User.create() }

    it "sends an alert when a zero graded submission is submitted" do
      allow(SettingsService).to receive(:get_settings).and_return('enable_regrading_alert' => true)
      allow(AlertsService::SecretManager).to receive(:get_secret).and_return({'API_ENDPOINT' => '12345'})
      allow(HTTParty).to receive(:post).and_return(AlertsService::Response.new(200, nil))
      expect(AlertsService::Client).to receive(:create)
      submission.update(submitted_at: Time.now)
    end

    it "doesn't send an alert when an lti-graded submission is submitted" do
      allow(SettingsService).to receive(:get_settings).and_return('enable_regrading_alert' => true)
      allow(AlertsService::SecretManager).to receive(:get_secret).and_return({'API_ENDPOINT' => '12345'})
      allow(HTTParty).to receive(:post).and_return(AlertsService::Response.new(200, nil))
      expect(AlertsService::Client).not_to receive(:create)
      submission.update(grader_id: -6, submitted_at: Time.now)
    end

    it "doesn't send an alert when an enable_regrading_alert is false" do
      allow(SettingsService).to receive(:get_settings).and_return('enable_regrading_alert' => false)
      expect(AlertsService::Client).not_to receive(:create)
      submission.update(submitted_at: Time.now)
    end

    it "doesn't send an alert for a discussion topic" do
      allow(SettingsService).to receive(:get_settings).and_return('enable_regrading_alert' => true)
      allow(AlertsService::SecretManager).to receive(:get_secret).and_return({'API_ENDPOINT' => '12345'})
      allow(HTTParty).to receive(:post).and_return(AlertsService::Response.new(200, nil))
      allow(submission).to receive(:submission_type).and_return('discussion_topic')
      expect(AlertsService::Client).to_not receive(:create)
      submission.update(submitted_at: Time.now)
    end 
  end
end