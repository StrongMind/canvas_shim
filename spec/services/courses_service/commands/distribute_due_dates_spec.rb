class ContentTag
end

describe CoursesService::Commands::DistributeDueDates do
  let(:course) do
    double(
      :course,
      start_at: Date.today,
      end_at: Date.today + 1.day,
      id: 1
    )
  end

  subject { described_class.new(course: course) }

  before do
    allow(ContentTag).to receive(:where).and_return(content_tags)
  end

  describe "#call" do
    it 'runs' do
      expect(assignment).to receive(:update)
      subject.call
    end
  end
end
