describe RequirementsService::Commands::MinScorePercentifier do
  include_context 'stubbed_network'
  subject { described_class.new(content_tag: content_tag, passing_threshold: 50) }

  let(:context_module) do 
    double(
      'context module', 
      completion_requirements: [],
      update_column: nil,
      touch: nil,
      content_tags: content_tags,
    )
  end

  let(:content_tag) do
    double(:content_tag, content: assignment)
  end

  let(:assignment) do
    Assignment.create(points_possible: 50)
  end

  describe "#points_possible" do
    context "no content" do
      let(:content_tag) do
        double(:content_tag, content: nil)
      end

      it "returns 100" do
        expect(subject.send(:points_possible)).to eq(100.0)
      end
    end

    context "no points possible" do
      let(:assignment) do
        Assignment.create
      end

      it "returns 100" do
        expect(subject.send(:points_possible)).to eq(100.0)
      end
    end

    context "Assignment with points possible" do
      let(:content_tag) do
        double(:content_tag, content: assignment)
      end

      it "returns assignment points possible" do
        expect(subject.send(:points_possible)).to eq(50.0)
      end
    end

    context "DiscussionTopic with Assignment with points possible" do
      let(:content_tag) do
        double(:content_tag, content: assignment)
      end

      let(:discussion_topic) do
        DiscussionTopic.create(assignment: assignment)
      end

      it "returns assignment points possible" do
        expect(subject.send(:points_possible)).to eq(50.0)
      end
    end
  end

  describe "#call" do
    it "will return half the points possible" do
      expect(subject.call).to eq(25.0)
    end

    context "no content" do
      let(:content_tag) do
        double(:content_tag, content: nil)
      end

      it "returns 100% of min score" do
        expect(subject.call).to eq(50.0)
      end
    end
  end
end
