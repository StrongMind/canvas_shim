describe CoursesService::Commands::DistributeDueDates::Scheduler do
  let(:start_at) { Date.parse("Thu Nov 29 2018") }
  let(:end_at)   { start_at + 1.month }
  let(:course)   { double(:course, start_at: start_at, end_at: end_at) }

  let(:days) do
    subject.course_dates.map { |d| d.strftime("%a") }.uniq
  end

  subject do
    described_class.new(course: course, assignment_count: 100)
  end

  describe '#course_days_count' do
    it 'should return a count of all weekdays' do
      expect(subject.course_days_count).to eq 22
    end
  end

  describe '#assignments_per_day' do
    it 'does assignment count / course_days_count' do
      expect(subject.assignments_per_day).to eq 100 / 22
    end
  end

  describe '#course_dates' do
    it do
      expect(days).to_not include("Sat")
    end
  end
end
