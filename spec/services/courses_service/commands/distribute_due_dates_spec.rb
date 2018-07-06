class ContentTag;end

describe CoursesService::Commands::DistributeDueDates do
  let(:course) do
    double(
      :course,
      start_at: start_at,
      end_at: end_at,
      id: 1
    )
  end

  let(:start_at) { Date.parse("Thu Nov 29 2018") }
  let(:end_at)   { start_at + 5.days }

  let(:ordered_content_tags) do
    [
      double(:content_tag, assignment: assignment),
      double(:content_tag, assignment: assignment2),
      double(:content_tag, assignment: assignment3)
    ]
  end

  let(:content_tags) { double(:content_tags, order: ordered_content_tags) }
  let(:assignment)  { double(:assignment) }
  let(:assignment2) { double(:assignment2) }
  let(:assignment3) { double(:assignment3) }

  subject { described_class.new(course: course) }

  before do
    allow(ContentTag).to receive(:where).and_return(content_tags)
  end

  describe "#call" do
    it 'distributes the assignments across workdays' do
      expect(assignment).to(
        receive(:update).with(due_at: Date.parse('Fri, 30 Nov 2018'))
      )

      expect(assignment2).to(
        receive(:update).with(nil)
      )
      
      expect(assignment3).to(
        receive(:update).with(nil)
      )
      subject.call
    end
  end
end
