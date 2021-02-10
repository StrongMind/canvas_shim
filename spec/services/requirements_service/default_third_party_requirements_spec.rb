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
      double(:content_tag, content_type: "Attachment", id: 5),
      double(:content_tag, content_type: "Quizzes::Quiz", id: 6),
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

    it "Sets an Attachment to must_view" do
      attachment = subject.send(:completion_requirements).find {|req| req[:id] == 5 }
      expect(attachment[:type]).to eq("must_view")
    end

    it "Sets an Quizzes::Quiz to must_submit" do
      quizzes = subject.send(:completion_requirements).find {|req| req[:id] == 6 }
      expect(quizzes[:type]).to eq("must_submit")
    end

    context "Requirement exists" do
      let(:context_module) do 
        double(
          'context module', 
          completion_requirements: [{id: 3, type: "must_submit"}],
          update_column: nil,
          touch: nil,
          content_tags: content_tags,
        )
      end

      it "Sets an WikiPage to must_view" do
        wiki_page = subject.send(:completion_requirements).find {|req| req[:id] == 3 }
        expect(wiki_page[:type]).to eq("must_submit")
      end
    end

    context "Has Subheader" do
      let!(:content_tags) do
        [
          double(:content_tag, content_type: "ContextModuleSubHeader", id: 1),
          double(:content_tag, content_type: "Assignment", id: 2),
          double(:content_tag, content_type: "DiscussionTopic", id: 3),
          double(:content_tag, content_type: "WikiPage", id: 4),
          double(:content_tag, content_type: "ContextExternalTool", id: 5),
          double(:content_tag, content_type: "Attachment", id: 6),
          double(:content_tag, content_type: "Quizzes::Quiz", id: 7),
        ]
      end

      it "Sets an WikiPage to must_view" do
        subject.send(:set_requirements)
        subheader = subject.send(:completion_requirements).find {|req| req[:id] == 1 }
        expect(subheader).to eq(nil)
      end
    end
  end

  describe "#add_prerequisites" do
    let(:first_context_module) do
      double(
        'context module',
        id: 1,
        completion_requirements: [],
        prerequisites: [],
        position: 1,
        name: "FIRST ONE",
        context_id: 1,
        update_column: nil,
        touch: nil,
        content_tags: content_tags,
      )
    end

    let(:second_context_module) do
      double(
        'context module',
        id: 2,
        completion_requirements: [],
        prerequisites: [],
        position: 2,
        name: "SECOND ONE",
        context_id: 1,
        update_column: nil,
        touch: nil,
        content_tags: content_tags,
      )
    end

    context "First module" do
      subject { described_class.new(context_module: first_context_module) }

      it "Does not set prerequisites to the first one" do
        expect(first_context_module).not_to receive(:update_column)
        subject.send(:add_prerequisites)
      end
    end

    context "Second module" do
      subject { described_class.new(context_module: second_context_module) }
      before do
        allow(subject).to receive(:find_last_context_module).and_return(first_context_module)
      end

      it "Does not set prerequisites to the first one" do
        expect(second_context_module).to receive(:update_column)
        subject.send(:add_prerequisites)
      end
    end
  end
end