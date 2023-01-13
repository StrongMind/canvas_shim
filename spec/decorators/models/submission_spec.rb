describe Submission do
  subject { described_class }
  include_context 'stubbed_network'
  
  let(:subject_instance) { double('subject_instance')}
  
  # before do
  #   allow(subject).to receive(:new).and_return(subject_instance)
  #   allow(subject_instance).to receive(:save)
  #   allow(subject_instance).to receive(:send_guided_practice_submitted_alert)
  # end
  
  describe 'callbacks' do
    describe 'send_guided_practice_submitted_alert' do
      let(:course) { create(:course) }
      let(:teacher) { create(:user) }
      let(:student) { create(:user) }
      let(:content_tag) { create(:content_tag, :with_assignment)}
      let(:teacher_enrollment) { create(:enrollment, user: teacher, course: course, type: 'TeacherEnrollment') }
      let(:student_enrollment) { create(:enrollment, user: student, course: course, type: 'StudentEnrollment') }
      
      it "should alert the teacher when a student submits a guided practice" do
        assignment = content_tag.content
        assignment.assignment_group.update(name: 'Guided Practice')
        alert_instance = instance_double(AlertsService::Client)
        allow(AlertsService::Client).to receive(:create).and_return(alert_instance)
        submission = Submission.new(user: student, assignment: assignment)
        binding.pry
        expect(submission).to receive(:send_guided_practice_submitted_alert)
        submission.save
        # expect(alert_instance).to have_received(:create).with(:guided_practice_submitted, teacher.id, student.id, assignment.id, course.id)
        # expect(subject_instance).to receive(:send_guided_practice_submitted_alert)
        # subject.create(user: student, assignment: assignment, course: course, workflow_state: 'submitted')
      end

    end
  end
end