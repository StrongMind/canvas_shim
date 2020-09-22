describe User do
  include_context 'stubbed_network'
  let(:course_1) { Course.create }
  let(:course_2) { Course.create }
  let(:student) { User.create }
  let(:parent) { User.create }
  let!(:observer_enrollment_1) do
    ObserverEnrollment.create(
      course: course_1,
      user: parent,
      associated_user: student
    )
  end

  let!(:observer_enrollment_2) do
    ObserverEnrollment.create(
      course: course_2,
      user: parent,
      associated_user: student
    )
  end

  let!(:student_enrollment_1) do
    StudentEnrollment.create(
      course: course_1,
      user: student,
    )
  end

  let!(:student_enrollment_2) do
    StudentEnrollment.create(
      course: course_2,
      user: student,
    )
  end

  let(:observed_ids) { [student.id] }

  before do
    parent.observed_users << student
  end

  it "soft-deletes observer enrollments" do
    parent.destroy_all_observations(observed_ids)
    expect(parent.observer_enrollments.active.none?).to be
  end

  it "soft-deletes user_observees" do
    parent.destroy_all_observations(observed_ids)
    expect(parent.user_observees.active.none?).to be
  end

  it "does not hard-delete enrollments" do
    parent.destroy_all_observations(observed_ids)
    expect(parent.user_observees.any?).to be
  end

  it "does not hard-delete user_observees" do
    parent.destroy_all_observations(observed_ids)
    expect(parent.user_observees.any?).to be
  end
end