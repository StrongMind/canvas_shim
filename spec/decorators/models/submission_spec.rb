describe Submission do
  subject { described_class }
  include_context 'stubbed_network'

  let(:subject_instance) { double('subject_instance') }
  let(:course) { create(:course) }
  let(:teacher) { create(:user) }
  let(:student) { create(:user) }
  let(:content_tag) { create(:content_tag, :with_assignment) }
  let(:teacher_enrollment) { create(:enrollment, user: teacher, course: course, type: 'TeacherEnrollment') }
  let(:student_enrollment) { create(:enrollment, user: student, course: course, type: 'StudentEnrollment') }

  describe 'callbacks' do
    describe '#send_guided_practice_submitted_alert' do
      context 'when the assignment is a Guided Practice' do
        it "should call #send_guided_practice_alert" do
          assignment = content_tag.content
          assignment.update(course_id: course.id)
          assignment.assignment_group.update(name: 'Guided Practice')
          submission = Submission.new(user: student, assignment: assignment)
          expect(submission).to receive(:send_guided_practice_submitted_alert)
          submission.update(submitted_at: Time.now)
        end

        it "should create a new AlertService::Client instance" do
          assignment = content_tag.content
          assignment.update(course_id: course.id)
          assignment.assignment_group.update(name: 'Guided Practice')
          course.enrollments.concat([teacher_enrollment, student_enrollment])
          submission = Submission.new(user: student, assignment: assignment)
          expect(AlertsService::Client).to receive(:create).with(:guided_practice_submitted, teacher_id: teacher.id, student_id: student.id, assignment_id: assignment.id, course_id: course.id)
          submission.update(submitted_at: Time.now)
        end
      end

      context 'when the assignment is not a Guided Practice' do
        it "should not call #send_guided_practice_alert" do
          assignment = content_tag.content
          assignment.update(course_id: course.id)
          assignment.assignment_group.update(name: 'Not Guided Practice')
          submission = Submission.new(user: student, assignment: assignment)
          expect(submission).not_to receive(:send_guided_practice_submitted_alert)
          submission.update(submitted_at: Time.now)
        end

        it "should not create a new AlertService::Client instance" do
          assignment = content_tag.content
          assignment.update(course_id: course.id)
          assignment.assignment_group.update(name: 'Not Guided Practice')
          course.enrollments.concat([teacher_enrollment, student_enrollment])
          submission = Submission.new(user: student, assignment: assignment)
          expect(AlertsService::Client).not_to receive(:create).with(:guided_practice_submitted, teacher_id: teacher.id, student_id: student.id, assignment_id: assignment.id, course_id: course.id)
          submission.update(submitted_at: Time.now)
        end
      end
    end
  end

  describe 'validations' do
    it 'is valid when body is less than or equal to 20,000 characters' do
      assignment = content_tag.content
      assignment.update(course_id: course.id)
      assignment.assignment_group.update(name: 'Guided Practice')
      submission = Submission.new(user: student, assignment: assignment, body: Faker::Lorem.characters(20_000))
      expect(submission).to be_valid
    end

    it 'is not valid when body is over 20,000 characters' do
      assignment = content_tag.content
      assignment.update(course_id: course.id)
      assignment.assignment_group.update(name: 'Guided Practice')
      submission = Submission.new(user: student, assignment: assignment, body: Faker::Lorem.characters(20_001))
      expect(submission).to_not be_valid
    end
  end
end
