describe CourseProgress do
  include_context 'stubbed_network'
  let(:user) { User.create }
  let(:user_2) { User.create }
  let(:observer) { User.create(observed_users: [user]) }
  let(:observer_2) { User.create(observed_users: [user, observer]) }
  let(:course) { Course.create }
  let(:course_progress_observer) { CourseProgress.new(course, observer) }
  let(:observer_enrollment) { Enrollment.create(user: observer, course: course, type: 'ObserverEnrollment', associated_user_id: user.id) }
  let(:course_progress_observer_2) { CourseProgress.new(course, observer_2) }
  let(:observer_enrollment_3) { Enrollment.create(user: observer_2, course: course, type: 'ObserverEnrollment', associated_user_id: observer.id) }
  let(:course_progress_student) { CourseProgress.new(course, user) }
  let(:student_enrollment) { Enrollment.create(user: user, course: course, type: 'StudentEnrollment') }
  let(:course_progress_student_2) { CourseProgress.new(course, user_2) }

  describe "#find_user_id" do
    it 'returns the first observed user' do
      Enrollment.create(user: observer, course: course, type: 'ObserverEnrollment', associated_user_id: user.id)
      Enrollment.create(user: observer_2, course: course, type: 'ObserverEnrollment', associated_user_id: user.id)
      expect(course_progress_observer.send(:find_user_id)).to eq(user.id)
      expect(course_progress_observer_2.send(:find_user_id)).to eq(user.id)
    end

    it 'returns the user if they have no observers' do
      expect(course_progress_student.send(:find_user_id)).to eq(user.id)
    end
  end

  describe "#allow_course_progress?" do
    before do
      Enrollment.create(user: observer, course: course, type: 'ObserverEnrollment', associated_user_id: user.id)
      Enrollment.create(user: observer_2, course: course, type: 'ObserverEnrollment', associated_user_id: user.id)
    end

    it "returns true if the user is enrolled as a student" do
      expect(course).to receive(:user_is_student?).with(user, :include_all=>true).and_return(true)
      expect(course_progress_student.send(:allow_course_progress?)).to be true
    end

    it "returns true if the user is observing a student" do
      expect(course).to receive(:user_is_student?).with(observer, :include_all=>true).and_return(false)
      expect(course).to receive(:user_is_student?).with(user, :include_all=>true).and_return(true)
      expect(course_progress_observer.send(:allow_course_progress?)).to be true
    end
  end

  describe "#requirement_count" do
    context "with excused submission" do
      let(:assn) { Assignment.create(course_id: course.id) }
      let(:assn_2) { Assignment.create(course_id: course.id) }
      let!(:sub) { Submission.create(assignment: assn, user: user) }
      let(:excused_sub) { Submission.create(assignment: assn_2, user: user) }
      let(:content_tag_1) { ContentTag.create }
      let(:content_tag_2) { ContentTag.create(content_id: assn.id, content_type: 'Assignment') }
      let(:content_tag_3) { ContentTag.create(content_id: assn_2.id, content_type: 'Assignment') }

        
      let(:fake_requirements) do
        [
          {:id=>content_tag_1.id, :type=>"must_view"},
          {:id=>content_tag_2.id, :type=>"must_submit"},
          {:id=>content_tag_3.id, :type=>"must_submit"}
        ]
      end

      before do
        allow(course_progress_student).to receive(:requirements).and_return(fake_requirements)
        allow(course_progress_student).to receive(:requirements_completed).and_return(fake_requirements[1..-1])
        excused_sub.update(excused: true)

      end

      it "removes excused submissions from requirement count" do
        expect(course_progress_student.send(:filter_out_excused_requirements, course_progress_student.requirements)).to eq(fake_requirements[0..1])
      end

      it "removes excused submissions from requirement completed count" do
        expect(course_progress_student.send(:filter_out_excused_requirements, course_progress_student.requirements_completed)).to eq([fake_requirements[1]])
      end
    end
  end
end
