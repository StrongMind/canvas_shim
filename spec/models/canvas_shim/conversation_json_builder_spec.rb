describe CanvasShim::ConversationJSONBuilder do
    subject { described_class }
  
    it "Return nil if the record can't be found" do
      expect(subject.call(id: 1)).to eq({})
    end
end
