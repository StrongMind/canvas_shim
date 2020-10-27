describe PipelineService::Commands::Publish do
  let(:object)              { PipelineService::Models::Noun.new(Enrollment.new) }
  let(:user)                { double('user') }
  let(:test_message)        { {} }
  let(:client_instance)     { double('pipeline_client', call: double('call_result', message: test_message)) }
  let(:client_class)        { double('pipeline_client_class', new: client_instance) }
  let(:serializer_class)    { double('serializer_class', new: serializer_instance) }
  let(:serializer_instance) { double('serializer_instance', call: nil) }
  let(:responder_instance)   { double('responder_instance') }
  let(:responder_class)      { double('responder_class', new: responder_instance) }

  before do
    allow(SettingsService).to receive(:get_settings).and_return({})
  end

  subject do
    described_class.new(
      object:       object,
      user:         user,
      client:       client_class,
      serializer:   serializer_class,
      responder:     responder_class
    )
  end

  describe '#call' do
    context 'no serializer' do
      let(:unknown_noun) do
        double(
          "unknown noun", 
          id: 1,
          class: double(
            'noun_class', 
            primary_key: 'id'
          )
        )
      end

      let(:object) do 
        PipelineService::Models::Noun.new(unknown_noun)
      end
      
      it 'will not try to publish' do
        expect(client_instance).to_not receive(:call)
        subject.call
      end
    end
    
    it 'sends a message to the pipeline' do
      expect(client_instance).to receive(:call)
      subject.call
    end

    describe "#post_to_pipeline" do
      include_context "stubbed_network"

      context "v2" do
        before do
          subject.instance_variable_set(:@client, PipelineService::V2::Client)
        end

        it "will send as v2 if client is specified" do
          expect(PipelineService::V2::Client).to receive(:publish)
          subject.send :post_to_pipeline
        end
      end
    end

    describe "#publisher_arguments" do
      context "v2" do
        before do
          subject.instance_variable_set(:@client, PipelineService::V2::Client)
        end

        it "has a fake logger" do
          expect(subject.send(:publisher_arguments)[:logger]).to eq("FakeLogger")
        end
      end

      it "Has normal logger otherwise" do
        expect(subject.send(:publisher_arguments)[:logger]).to eq(nil)
      end
    end

    it 'can be turned off' do
      allow(SettingsService).to receive(:get_settings).and_return({'disable_pipeline' => true})
      expect(client_instance).to_not receive(:call)
      subject.call
    end
  end
end
