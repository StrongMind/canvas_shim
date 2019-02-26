describe PipelineService::Nouns::Conversation::Builder do
    subject { described_class }

    include_context('pipeline_context')

    let!(:ar_object) { c = Conversation.create; c.destroy }
    let(:noun) { PipelineService::Nouns::Base.new(ar_object) }
  
    it "Return empty hash body if the record can't be found" do
      expect(subject.call(noun)).to eq({})
    end

    context do
      subject { described_class.new(object: noun) }

      let(:noun) { PipelineService::Nouns::Base.new(conversation_model) }
      let(:conversation_model) { Conversation.create }

      it 'returns an attribute hash for the noun' do
        expect(subject.call).to eq( { "id" => conversation_model.id } )
      end

      it 'returns an empty hash if the conversation can not be found' do
        conversation_model.destroy
        expect(subject.call).to eq( {} )
      end
    end
end
