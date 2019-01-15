describe AssignmentsService::Commands::DistributeDueDates::Scheduler do
  let(:start_at) { DateTime.parse("Mon Nov 26 2018") }
  let(:end_at) { start_at + 30.days }
  let(:course) { double(:course, start_at: start_at, end_at: end_at, time_zone: 'UTC') }

  let(:days) do
    subject.course_dates.keys.map { |d| d.strftime("%a") }.uniq
  end

  subject do
    described_class.new(course: course, assignment_count: 44)
  end

  describe '#course_days_count' do
    it 'should return a count of all weekdays' do
      expect(subject.course_days_count).to eq 29
    end
  end

  describe '#assignments_per_day' do
    it 'does assignment count / course_days_count' do
      expect(subject.assignments_per_day).to eq 2
    end

    context 'assignments dont divide evenly into course days' do
      subject do
        described_class.new(course: course, assignment_count: 22)
      end

      it 'distributes remainder' do
        expect(subject.course_dates[subject.course_dates.keys[0]]).to eq 2
        expect(subject.course_dates[subject.course_dates.keys[1]]).to eq 1
      end
    end
  end

  describe '#course_dates' do
    it 'does not include weekends' do
      expect(days).to_not include("Sat")
    end

    it 'will not assign a due date on the first day of the course' do
      expect(subject.course_dates.keys[0]).to_not eq start_at
    end

    it 'will start a day after' do
      expect(subject.course_dates.keys[0]).to eq start_at.in_time_zone(course.time_zone).at_end_of_day + 1.day
    end

    it 'will have a due time of 23:59' do
      expect(subject.course_dates.keys[0].strftime("%H:%M")). to eq "23:59"
    end

    context 'when given a start date' do
      subject do
        described_class.new(course: course, assignment_count: 44, start_date: DateTime.new(2018,12,6))
      end

      it 'will start a day after' do
        expect(subject.course_dates.keys[0].strftime("%Y-%m-%d")). to eq (DateTime.new(2018,12,7)).strftime('%Y-%m-%d')
      end
    end

    context 'when given holidays' do
        before do
          ENV['HOLIDAYS'] = "2018-11-28,2018-11-29"
        end

        after do
          ENV['HOLIDAYS'] = nil
        end

        it 'will not include the first holiday in course dates' do
          expect(subject.course_dates.keys[1].strftime("%F")). to_not eq "2018-11-28"
        end

        it 'will not include more holidays in course dates' do
          expect(subject.course_dates.keys[1].strftime("%F")). to_not eq "2018-11-29"
        end
    end
  end
end
