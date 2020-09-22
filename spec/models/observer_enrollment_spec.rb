describe ObserverEnrollment do
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

  let(:contexts) { [course_1, course_2] }
  

  before(:all) do
    # have to use a version without sharding for test
    def ObserverEnrollment.observed_enrollments_for_courses(contexts, user)
      contexts = Array(contexts)
      observed_students = []
      sharded_contexts = contexts.pluck(:id)
      observer_enrollment_data = user.observer_enrollments.active.where(course_id: sharded_contexts)
        .where('associated_user_id IS NOT NULL').pluck(:course_id, :associated_user_id)
      observer_enrollment_data.group_by(&:first).each do |course_id, course_enroll_data|
        associated_user_ids = course_enroll_data.map(&:last)
        students = StudentEnrollment.active.where(user_id: associated_user_ids, course_id: course_id)
        observed_students.concat(students)
      end
      observed_students
    end
  end

  context "One enrollment gets deleted" do
    before do
      observer_enrollment_2.destroy
      parent.reload
    end

    it "only has one" do
      enrs = ObserverEnrollment.observed_enrollments_for_courses(contexts, parent)
      expect(enrs.size).to eq 1
    end
  end

  context "Happy path" do
    it "has two" do
      enrs = ObserverEnrollment.observed_enrollments_for_courses(contexts, parent)
      expect(enrs.size).to eq 2
    end
  end
end