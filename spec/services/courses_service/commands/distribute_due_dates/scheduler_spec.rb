describe CoursesService::Commands::DistributeDueDates::Scheduler do
  let(:start_at) { Date.parse("Mon Nov 26 2018") }
  let(:end_at) { start_at + 30.days }
  let(:course) { double(:course, start_at: start_at, end_at: end_at) }

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
  end
end
