describe SubmissionComment do
  include_context "stubbed_network"

  describe '#send_feedback_alert' do
    let(:course) { Course.create(users: [teacher, student]) }
    let(:teacher) { User.create }
    let(:student) { User.create }
    let(:assignment) { create(:assignment, :with_assignment_group, course: course) }
    let(:submission) { Submission.create(user: student, assignment: assignment) }
    let(:teacher_enrollments) { course.enrollments.where(user: teacher) }
    let(:student_enrollments) { course.enrollments.where(user: student) }

    before do
      allow(course).to receive(:teacher_enrollments).and_return(teacher_enrollments)
      allow(course).to receive(:student_enrollments).and_return(student_enrollments)
      allow(SettingsService).to receive(:get_settings).and_return('reply_alerts' => true)
    end

    it "sends alert when the student submits a comment" do
      expect(AlertsService::Client).to receive(:create)
      SubmissionComment.create(
        context: course,
        author: student,
        submission: submission,
        comment: "Forks are not sporks"
      )
    end

    it "does not send when comment is not from student" do
      expect(AlertsService::Client).not_to receive(:create)
      SubmissionComment.create(
        context: course,
        author: teacher,
        submission: submission,
        comment: "Forks are not sporks"
      )
    end
  end
end