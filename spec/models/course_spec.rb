describe Course do
  include_context "stubbed_network"

  describe "#after_commit" do
    it 'does publish to the pipeline' do
      expect(PipelineService).to receive(:publish)
      Course.create
    end
  end

  describe "#online_user_count" do
    let(:course) { Course.create }
    let(:user_1) { User.create }
    let(:user_2) { User.create }
    let(:user_3) { User.create }
    let!(:enrollment_1) { Enrollment.create(course: course, user: user_1, workflow_state: 'active', type: 'StudentEnrollment') }
    let!(:enrollment_2) { Enrollment.create(course: course, user: user_2, workflow_state: 'inactive', type: 'StudentEnrollment') }
    let!(:enrollment_3) { Enrollment.create(course: course, user: user_3, workflow_state: 'active', type: 'TeacherEnrollment') }
    
    it "returns the count of 2 users online in the last 5 minutes" do
      current_time = Time.now.utc
      allow(Time).to receive(:now).and_return(current_time)
      allow(Rails.cache).to receive(:fetch).and_yield
      allow(Rails.cache).to receive(:read_multi) do |*keys|
        {
          "#{user_1.id}/last_access_time" => current_time - 2.minutes,  # Active and recent
          "#{user_2.id}/last_access_time" => current_time - 10.minutes, # Inactive and old
          "#{user_3.id}/last_access_time" => current_time - 1.minute    # Active and recent
        }
      end
      expect(course.online_user_count).to eq(2)
    end
  end


  describe "#no_active_students" do
    let(:first_user) { User.create }
    context "inactive student course" do
      let(:inactive_course) { Course.create }
      let(:inactive_enrollment_1) { Enrollment.create(course: inactive_course, user: first_user, workflow_state: 'invited', type: 'StudentEnrollment') }

      it "works with an inactive enrollment" do
        expect(inactive_course.no_active_students?).to be true
      end

      it "works with no enrollments" do
        expect(Course.create.no_active_students?).to be true
      end
    end

    context "active course" do
      let(:active_course) { Course.create }
      let!(:active_enrollment_1) { Enrollment.create(course: active_course, user: first_user, workflow_state: 'active', type: 'StudentEnrollment') }

      it "returns false when students are active in course" do
        expect(active_course.no_active_students?).to be false
      end
    end
  end

  describe "#average_score" do
    let!(:course) { Course.create }
    let!(:student) { User.create }
    let!(:student_enrollment) do
      StudentEnrollment.create(course: course, user: student, workflow_state: "active")
    end
    let!(:score_1) { Score.create(enrollment: student_enrollment, current_score: 87.0)}

    it "gets an average" do
      expect(course.average_score).to eq(87.0)
    end

    context "multiple students" do
      let!(:student_enrollment_2) do
        StudentEnrollment.create(course: course, user: student, workflow_state: "active")
      end
      let!(:score_2) { Score.create(enrollment: student_enrollment_2, current_score: 50.0)}
      let!(:student_enrollment_3) do
        StudentEnrollment.create(course: course, user: student, workflow_state: "active")
      end
      let!(:score_3) { Score.create(enrollment: student_enrollment_3, current_score: 60.0)}

      it "is different now" do
        expect(course.average_score.round(1)).to eq(65.7)
      end
    end

    it "returns 0 with no students" do
      expect(Course.create.average_score).to eq(0)
    end
  end

  describe "#needs_grading_count" do
    let!(:course) { Course.create }


    it "returns all needs grading assignments" do
      3.times do
        Assignment.create(course: course)
      end

      allow_any_instance_of(Assignment).to receive(:needs_grading_count).and_return(3)
      expect(course.needs_grading_count).to eq(9)
    end

    it "returns 0 with no assignments needing grading" do
      expect(Course.create.needs_grading_count).to eq(0)
    end
  end

  describe "#snapshot_students" do
    let(:course) { Course.create }
    let(:user) { User.create(name: "Chris Young") }
    let!(:enrollment) { StudentEnrollment.create(user: user, course: course, workflow_state: "active") }
    let(:stu_arr) { [enrollment.id, user.id, user.name] }

    before do
      Pseudonym.create!(user: user, unique_id: "12345", sis_user_id: "12345")
      Pseudonym.create!(user: user, unique_id: "123456")
    end

    describe "#get_snapshot_sis_ids" do
      it "returns the plucked sis ids" do
        expect(course.send(:get_snapshot_sis_ids, stu_arr)).to eq(
          ["12345", nil]
        )
      end
    end

    it "concatenates sis_ids with plucked enrollment values" do
      expect(course.snapshot_students).to eq(
        [[enrollment.id, user.id, user.name, "12345", nil]]
      )
    end

    it "concatenates sis_ids with plucked enrollment values" do
      user.pseudonyms.last.update(sis_user_id: "23456")
      expect(course.snapshot_students).to eq(
        [[enrollment.id, user.id, user.name, "12345", "23456"]]
      )
    end

    it "concatenates sis_ids with plucked enrollment values" do
      user.update(pseudonyms: [])
      expect(course.snapshot_students).to eq(
        [[enrollment.id, user.id, user.name]]
      )
    end

    context "two users" do
      let(:user_2) { User.create(name: "Not Chris Young") }
      let!(:enrollment_2) { StudentEnrollment.create(user: user_2, course: course, workflow_state: "active") }

      before do
        Pseudonym.create!(user: user_2, unique_id: "12345", sis_user_id: "12345")
        Pseudonym.create!(user: user_2, sis_user_id: "23456")
        allow(user_2).to receive(:name).and_return("Not Chris Young")
      end

      it "creates a single row per user" do
        expect(course.snapshot_students.size).to eq(2)
      end
    end
  end

  describe "#course_start_time_from_school" do
    context 'on create' do
      let(:course) { Course.create(start_at: '2025-06-24 06:59:00' ) }

      context "when start_time is present" do
        before do
          allow(SettingsService).to receive(:get_settings).and_return('course_start_time' => "12:05 AM MST")
        end

        let(:expected_start_time) { "07:05 AM UTC" }
        let(:expected_start_date) { "2025-06-24" }
        let(:actual_start_time) { course.start_at.strftime("%H:%M %p %Z") }
        let(:actual_start_date) { course.start_at.in_time_zone('Arizona').strftime("%Y-%m-%d") }

        it "matches start time in account settings" do
          expect(actual_start_time).to eq(expected_start_time)
        end

        it "returns the correct date for MST" do
          expect(actual_start_date).to eq(expected_start_date)
        end

        context 'when the course has a meta-programmed time_zone' do
          let(:time_zone) { ActiveSupport::TimeZone["America/Phoenix"] }

          before do
            def course.time_zone
              time_zone
            end
          end

          it "it does not effect the saved start_at time" do
            expect(actual_start_time).to eq(expected_start_time)
          end
        end

        context 'with a rollover date' do
          before do
            allow(SettingsService).to receive(:get_settings).and_return('course_start_time' => "11:55 PM MST")
          end

          it "returns the correct date for MST" do
            expect(actual_start_date).to eq(expected_start_date)
          end

          it "saves the date with the correct offset" do
            expect(course.start_at.day).to eq(25)
          end
        end
      end

      context "when start_time is not present" do
        let(:course) { Course.create() }
        it "creates a course without a start_at" do
          expect(course.start_at).to be nil
        end
      end
    end
  end

  describe "#course_end_time_from_school" do
    context 'on create' do
      let(:course) { Course.create(conclude_at: '2025-06-24 06:59:00') }

      context "when conclude_at is present" do
        context 'when the UTC date rolls over' do
          context 'when course_end_time is in MST' do
            before do
              allow(SettingsService).to receive(:get_settings).and_return('course_end_time' => "11:55 PM MST")
            end

            let(:expected_end_time) { "06:55 AM" }
            let(:actual_end_time) {  course.conclude_at.strftime("%H:%M %p") }
            let(:expected_end_date) { "2025-06-24" }

            it "matches the time in the account settings" do
              expect(actual_end_time).to eq(expected_end_time)
            end

            it "returns the correct date for MST" do
              actual_end_date = course.conclude_at.in_time_zone('Arizona').strftime("%Y-%m-%d")
              expect(actual_end_date).to eq(expected_end_date)
            end

            it "saves the date with the correct offset" do
              expect(course.conclude_at.day).to eq(25)
            end

            context 'when it is the end of the month' do
              context 'for January' do
                let(:course) { Course.create(conclude_at: '2025-01-31 06:59:00') }
                let(:expected_end_date) { "2025-01-31" }

                it "returns the correct date for MST" do
                  actual_end_date = course.conclude_at.in_time_zone('Arizona').strftime("%Y-%m-%d")
                  expect(actual_end_date).to eq(expected_end_date)
                end

                it "saves the date with the correct offset" do
                  expect(course.conclude_at.day).to eq(01)
                  expect(course.conclude_at.month).to eq(02)
                end
              end

              context 'for February (for a non-leap year)' do
                let(:course) { Course.create(conclude_at: '2023-02-28 06:59:00') }
                let(:expected_end_date) { "2023-02-28" }

                it "returns the correct date for MST" do
                  actual_end_date = course.conclude_at.in_time_zone('Arizona').strftime("%Y-%m-%d")
                  expect(actual_end_date).to eq(expected_end_date)
                end

                it "saves the date with the correct offset" do
                  expect(course.conclude_at.day).to eq(01)
                  expect(course.conclude_at.month).to eq(03)
                end
              end
            end

            context 'when it is the end of the year' do
              let(:course) { Course.create(conclude_at: '2025-12-31 06:59:00') }
              let(:expected_end_date) { "2025-12-31" }

              it "returns the correct date for MST" do
                actual_end_date = course.conclude_at.in_time_zone('Arizona').strftime("%Y-%m-%d")
                expect(actual_end_date).to eq(expected_end_date)
              end

              it "saves the date with the correct offset" do
                expect(course.conclude_at.day).to eq(01)
                expect(course.conclude_at.month).to eq(01)
                expect(course.conclude_at.year).to eq(2026)
              end
            end
          end

          context 'when course_end_time is in another timezone' do
            before do
              allow(SettingsService).to receive(:get_settings).and_return('course_end_time' => "11:55 PM EDT", 'timezone' => "ET")
            end

            let(:expected_end_time) { "03:55 AM" }
            let(:expected_end_date) { "2025-06-24" }

            it "matches the time in the account settings" do
              actual_end_time = course.conclude_at.strftime("%H:%M %p")
              expect(actual_end_time).to eq(expected_end_time)
            end

            it "returns the correct date for MST" do
              actual_end_date = course.conclude_at.in_time_zone('Eastern Time (US & Canada)').strftime("%Y-%m-%d")
              expect(actual_end_date).to eq(expected_end_date)
            end

            it "saves the date with the correct offset" do
              expect(course.conclude_at.day).to eq(25)
            end
          end

          context 'when SettingsService course_end_time is in a daylight savings timezone' do
            before do
              allow(SettingsService).to receive(:get_settings).and_return({ 'course_end_time' => "11:59 PM MDT", 'timezone' => "MT" })
            end

            context 'when the course concludes at a time when daylight savings is not observed' do
              let(:course_concluding_during_standard_time) { Course.create(conclude_at: '2025-1-10 01:23:45' ) }

              it 'returns the standard time-zone time' do
                actual_end_time = course_concluding_during_standard_time.conclude_at.strftime("%H:%M %p")
                expect(actual_end_time).to eq("06:59 AM")
              end
            end

            context 'when the course concludes at a time when daylight savings is observed' do
              let(:course_concluding_during_daylight_time) { Course.create(conclude_at: '2024-10-28 01:23:45' ) }

              it 'returns the daylight time-zone time' do
                actual_end_time = course_concluding_during_daylight_time.conclude_at.strftime("%H:%M %p")
                expect(actual_end_time).to eq("05:59 AM")
              end
            end
          end
        end

        context 'when the UTC date does not roll over' do
          before do
            allow(SettingsService).to receive(:get_settings).and_return('course_end_time' => "9:00 AM MST")
          end

          let(:expected_end_time) { "16:00 PM" }
          let(:expected_end_date) { "2025-06-24" }

          it "matches the time in the account settings" do
            actual_end_time = course.conclude_at.strftime("%H:%M %p")
            expect(actual_end_time).to eq(expected_end_time)
          end

          it "returns the correct date for MST" do
            actual_end_date = course.conclude_at.in_time_zone('Arizona').strftime("%Y-%m-%d")
            expect(actual_end_date).to eq(expected_end_date)
          end

          it "saves the date with the correct offset" do
            expect(course.conclude_at.day).to eq(24)
          end
        end
      end

      context "when conclude_at is not present" do
        let(:course) { Course.create() }
        it "creates a course without a conclude_at" do
          expect(course.conclude_at).to be nil
        end
      end
    end

    context 'on update' do
      context 'when not updating time zones' do
      let(:course) { Course.create(conclude_at: '2025-06-24 06:59:00') }

        before do
          allow(SettingsService).to receive(:get_settings).and_return('course_end_time' => "11:55 PM MST")
        end
        let(:expected_end_time) { "06:55 AM" }
        let(:actual_end_time) {  course.conclude_at.strftime("%H:%M %p") }
        let(:expected_end_date_after_create) { "2025-06-25" }

        it "It does not change the existing conclude_at" do
          actual_end_date = course.conclude_at.strftime("%Y-%m-%d")
          expect(actual_end_date).to eq(expected_end_date_after_create)
          course.update(workflow_state: 'active')

          actual_end_date = course.conclude_at.strftime("%Y-%m-%d")
          expect(actual_end_date).to eq(expected_end_date_after_create)
        end
      end
      context 'when updating time zones using #save_with_account_times' do
        let(:course) { Course.create }

        context "when conclude_at is present" do
          context 'when the UTC date rolls over' do
            context 'when course_end_time is in MST' do
              before do
                allow(SettingsService).to receive(:get_settings).and_return('course_end_time' => "11:55 PM MST")
                course.conclude_at ='2025-06-24 06:59:00'
                course.save_with_account_times
              end

              let(:expected_end_time) { "06:55 AM" }
              let(:actual_end_time) {  course.conclude_at.strftime("%H:%M %p") }
              let(:expected_end_date) { "2025-06-24" }

              it "matches the time in the account settings" do
                expect(actual_end_time).to eq(expected_end_time)
              end

              it "returns the correct date for MST" do
                actual_end_date = course.conclude_at.in_time_zone('Arizona').strftime("%Y-%m-%d")
                expect(actual_end_date).to eq(expected_end_date)
              end

              it "saves the date with the correct offset" do
                expect(course.conclude_at.day).to eq(25)
              end

              context 'when it is the end of the month' do
                context 'for January' do
                  let(:course) { Course.create }
                  let(:expected_end_date) { "2025-01-31" }

                  before do
                    course.conclude_at = '2025-01-31 06:59:00'
                    course.set_course_start_end_time_from_school.save
                  end

                  it "returns the correct date for MST" do
                    actual_end_date = course.conclude_at.in_time_zone('Arizona').strftime("%Y-%m-%d")
                    expect(actual_end_date).to eq(expected_end_date)
                  end

                  it "saves the date with the correct offset" do
                    expect(course.conclude_at.day).to eq(01)
                    expect(course.conclude_at.month).to eq(02)
                  end
                end

                context 'for February (for a non-leap year)' do
                  let(:course) { Course.create }
                  let(:expected_end_date) { "2023-02-28" }

                  before do
                    course.conclude_at = '2023-02-28 06:59:00'
                    course.set_course_start_end_time_from_school.save
                  end

                  it "returns the correct date for MST" do
                    actual_end_date = course.conclude_at.in_time_zone('Arizona').strftime("%Y-%m-%d")
                    expect(actual_end_date).to eq(expected_end_date)
                  end

                  it "saves the date with the correct offset" do
                    expect(course.conclude_at.day).to eq(01)
                    expect(course.conclude_at.month).to eq(03)
                  end
                end
              end

              context 'when it is the end of the year' do
                let(:course) { Course.create }
                let(:expected_end_date) { "2025-12-31" }

                before do
                  course.conclude_at = '2025-12-31 06:59:00'
                  course.set_course_start_end_time_from_school.save
                end

                it "returns the correct date for MST" do
                  actual_end_date = course.conclude_at.in_time_zone('Arizona').strftime("%Y-%m-%d")
                  expect(actual_end_date).to eq(expected_end_date)
                end

                it "saves the date with the correct offset" do
                  expect(course.conclude_at.day).to eq(01)
                  expect(course.conclude_at.month).to eq(01)
                  expect(course.conclude_at.year).to eq(2026)
                end
              end
            end

            context 'when course_end_time is in another timezone' do
              before do
                allow(SettingsService).to receive(:get_settings).and_return({'course_end_time' => "11:55 PM EDT", 'timezone' => "ET"})
                course.conclude_at = '2025-06-24 06:59:00'
                course.save_with_account_times

              end

              let(:expected_end_time) { "03:55 AM" }
              let(:expected_end_date) { "2025-06-24" }

              it "matches the time in the account settings" do
                actual_end_time = course.conclude_at.strftime("%H:%M %p")
                expect(actual_end_time).to eq(expected_end_time)
              end

              it "returns the correct date for MST" do
                actual_end_date = course.conclude_at.in_time_zone('Eastern Time (US & Canada)').strftime("%Y-%m-%d")
                expect(actual_end_date).to eq(expected_end_date)
              end

              it "saves the date with the correct offset" do
                expect(course.conclude_at.day).to eq(25)
              end
            end
          end

          context 'when the UTC date does not roll over' do
            before do
              allow(SettingsService).to receive(:get_settings).and_return('course_end_time' => "9:00 AM MST")
              course.conclude_at = '2025-06-24 06:59:00'
              course.save_with_account_times

            end

            let(:expected_end_time) { "16:00 PM" }
            let(:expected_end_date) { "2025-06-24" }

            it "matches the time in the account settings" do
              actual_end_time = course.conclude_at.strftime("%H:%M %p")
              expect(actual_end_time).to eq(expected_end_time)
            end

            it "returns the correct date for MST" do
              actual_end_date = course.conclude_at.in_time_zone('Arizona').strftime("%Y-%m-%d")
              expect(actual_end_date).to eq(expected_end_date)
            end

            it "saves the date with the correct offset" do
              expect(course.conclude_at.day).to eq(24)
            end
          end
        end

        # This context does not seem to describe the current behavior
        context "when set_course_start_end_time_from_school is not called" do
          context 'when the the school time is in MST' do
            let(:course) { Course.create(conclude_at: '2025-06-24 06:59:00') }

            before do
              allow(SettingsService).to receive(:get_settings).and_return('course_end_time' => "11:55 PM MST")
            end
            let(:expected_end_time) { "06:55 AM" }
            let(:actual_end_time) {  course.conclude_at.strftime("%H:%M %p") }
            let(:expected_end_date) { "2025-06-25" }

            it "does change the existing conclude_at" do
              actual_end_date = course.conclude_at.strftime("%Y-%m-%d")
              expect(actual_end_date).to eq(expected_end_date)
              course.update(workflow_state: 'active')

              actual_end_date = course.conclude_at.strftime("%Y-%m-%d")
              expect(actual_end_date).to eq(expected_end_date)
            end
          end
          context 'when the school time is in UTC' do
            let(:course) { Course.create(conclude_at: '2025-06-24 06:59:00') }

            before do
              allow(SettingsService).to receive(:get_settings).and_return({'course_end_time' => "11:55 PM UTC", 'timezone' => "UTC"})
            end
            let(:expected_end_time) { "06:55 AM" }
            let(:actual_end_time) {  course.conclude_at.strftime("%H:%M %p") }
            let(:expected_end_date) { "2025-06-24" }

            it "It does not change the existing conclude_at" do
              actual_end_date = course.conclude_at.strftime("%Y-%m-%d")
              expect(actual_end_date).to eq(expected_end_date)
              course.update(workflow_state: 'active')

              actual_end_date = course.conclude_at.strftime("%Y-%m-%d")
              expect(actual_end_date).to eq(expected_end_date)
            end
          end
          context 'when the the school time is in MDT' do
            let(:course) { Course.create(conclude_at: '2025-06-24 06:59:00') }

            before do
              allow(SettingsService).to receive(:get_settings).and_return({'course_end_time' => "11:55 PM MDT", 'timezone' => "MT"})
            end
            let(:expected_end_time) { "06:55 AM" }
            let(:actual_end_time) {  course.conclude_at.strftime("%H:%M %p") }
            let(:expected_end_date) { "2025-06-25" }

            it "does change the existing conclude_at" do
              actual_end_date = course.conclude_at.strftime("%Y-%m-%d")
              expect(actual_end_date).to eq(expected_end_date)
              course.update(workflow_state: 'active')

              actual_end_date = course.conclude_at.strftime("%Y-%m-%d")
              expect(actual_end_date).to eq(expected_end_date)
            end
          end
        end
      end
    end
  end

  describe '#parse_time_in_school_timezone' do
    let(:course) { Course.create }
    context 'when the time is in MT' do
      before do
        allow(SettingsService).to receive(:get_settings).and_return('timezone' => 'MT')
      end
      it 'returns the correct date with an offset of 6 when observing daylight savings' do
        expect(course.parse_time_in_school_timezone('1:00 AM MDT', '2024-10-05 06:59:00 UTC')).to eq('2024-10-05 01:00:00.000000000 -0600')
      end
      it 'returns the correct date with an offset of 7 when not observing daylight savings' do
          expect(course.parse_time_in_school_timezone('1:00 AM MDT', '2024-11-05 06:59:00 UTC')).to eq('2024-11-05 01:00:00.000000000 -0700')
      end
    end
  end
end
