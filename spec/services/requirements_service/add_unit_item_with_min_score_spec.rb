describe RequirementsService::Commands::AddUnitItemWithMinScore do
  include_context 'stubbed_network'
  subject { described_class.new(context_module: context_module, content_tag: content_tag, assignment_group_name: nil) }
  before do
    allow(subject).to receive(:score_threshold).and_return(70.0)
  end

  let(:content_tag) { ContentTag.create(content_type: "DiscussionTopic") }
  
  let(:course) { Course.create() }
  
  let(:context_module) do 
    ContextModule.create( 
      completion_requirements: completion_requirements,
      course: course,
    ) 
  end

  let(:completion_requirements) do
    [
      {:id=>53, :type=>"must_view"},
      {:id=>56, :type=>"must_submit"},
      {:id=>58, :type=>"must_contribute"}
    ]
  end

  describe "#call" do
    let(:content_tag_2) { ContentTag.create(content_type: "FunTime") }

    it "adds a completion requirement with min score" do
      subject.call
      expect(context_module.completion_requirements).not_to include({:id=>content_tag_2.id, :type=>"min_score", :min_score => 70.0})
    end
  end
end