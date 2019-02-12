describe PipelineService::Builders::ConversationJSONBuilder do
    subject { described_class }

    include_context('pipeline_context')

    let!(:ar_object) { c = Conversation.create; c.destroy }
  
    it "Return empty hash body if the record can't be found" do
      expect(subject.call(ar_object)).to eq({})
    end
end
