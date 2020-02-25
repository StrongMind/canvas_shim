describe RequirementsService::Commands::DefaultThirdPartyRequirements do
  subject { described_class.new(context_module: context_module) }

  let(:context_module) do 
    double(
      'context module', 
      completion_requirements: [],
      update_column: nil,
      touch: nil,
      content_tags: content_tags,
    )
  end

  let(:content_tags) do
    [
      double(:content_tag, content_type: "Assignment", id: 1),
      double(:content_tag, content_type: "DiscussionTopic", id: 2),
      double(:content_tag, content_type: "WikiPage", id: 3),
      double(:content_tag, content_type: "ContextExternalTool", id: 4),
    ]
  end

  describe "#set_requirements" do
    before do
      subject.send(:set_requirements)
    end

    it "Sets an assignment to must_submit" do
      assignment = subject.send(:completion_requirements).find {|req| req[:id] == 1 }
      expect(assignment[:type]).to eq("must_submit")
    end

    it "Sets an Discussion Topic to must_contribute" do
      discussion_topic = subject.send(:completion_requirements).find {|req| req[:id] == 2 }
      expect(discussion_topic[:type]).to eq("must_contribute")
    end

    it "Sets an WikiPage to must_view" do
      wiki_page = subject.send(:completion_requirements).find {|req| req[:id] == 3 }
      expect(wiki_page[:type]).to eq("must_view")
    end
  end
end