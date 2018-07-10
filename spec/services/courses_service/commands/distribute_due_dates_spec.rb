class ContentTag;end
class ContextModule;end

describe CoursesService::Commands::DistributeDueDates do
  let(:start_at) { Date.parse("Mon Nov 26 2018") }
  let(:end_at)   { start_at + 5.days }
  let(:course) do
    double(
      :course,
      start_at: start_at,
      end_at: end_at,
      id: 1
    )
  end

  let(:ordered_content_tags) do
    [
      double(:content_tag, assignment: assignment),
      double(:content_tag, assignment: assignment2),
      double(:content_tag, assignment: assignment3),
      double(:content_tag, assignment: assignment4),
      double(:content_tag, assignment: assignment5),
      double(:content_tag, assignment: assignment6),
      double(:content_tag, assignment: assignment7),
      double(:content_tag, assignment: assignment8),
      double(:content_tag, assignment: assignment9),
      double(:content_tag, assignment: assignment10)
    ]
  end

  let(:ordered_context_modules) do
    [
      double(:context_module, content_tags: double(:context_module, where: content_tags))
    ]
  end

  let(:content_tags) { double(:content_tags, order: ordered_content_tags) }
  let(:assignment)  { double(:assignment) }
  let(:assignment2) { double(:assignment2, update: nil) }
  let(:assignment3) { double(:assignment3, update: nil) }
  let(:assignment4)  { double(:assignment4, update: nil) }
  let(:assignment5) { double(:assignment5, update: nil) }
  let(:assignment6) { double(:assignment6, update: nil) }
  let(:assignment7) { double(:assignment7, update: nil) }
  let(:assignment8) { double(:assignment8, update: nil) }
  let(:assignment9) { double(:assignment9, update: nil) }
  let(:assignment10) { double(:assignment10, update: nil) }
  let(:context_modules) { double(:context_modules, order: ordered_context_modules) }

  subject { described_class.new(course: course) }

  before do
    allow(ContentTag).to receive(:where).and_return(content_tags)
    allow(ContextModule).to receive(:where).and_return(context_modules)
    ENV["AUTOMATIC_DUE_DATES"] = "true"
  end

  describe "#call" do
    context 'instance has no automatic due date setting' do
      before do
        # thing to fake environment setting
        ENV["AUTOMATIC_DUE_DATES"] = nil
      end

      it 'will not distribute the due dates' do 
        expect(assignment).to_not(receive(:update))
        subject.call
      end
    end
    context 'course without start date' do
      let(:course) do
        double(
          :course,
          start_at: nil,
          end_at: start_at + 5.days,
          id: 1
        )
      end

      it 'wont distribute the due dates' do
        expect(assignment).to_not(receive(:update))
        subject.call
      end
    end

    context 'course without end date' do
      let(:course) do
        double(
          :course,
          start_at: start_at,
          end_at: nil,
          id: 1
        )
      end

      it 'wont distribute the due dates' do
        expect(assignment).to_not(receive(:update))
        subject.call
      end
    end


    it 'distributes the assignments across workdays' do
      expect(assignment).to(
        receive(:update).with(due_at: Date.parse('Mon, 27 Nov 2018'))
      )

      expect(assignment2).to(
        receive(:update).with(due_at: Date.parse('Tue, 27 Nov 2018'))
      )

      expect(assignment3).to(
        receive(:update).with(due_at: Date.parse('Wed, 27 Nov 2018'))
      )

      expect(assignment4).to(
        receive(:update).with(due_at: Date.parse('Wed, 28 Nov 2018'))
      )
      subject.call
    end
  end
end
