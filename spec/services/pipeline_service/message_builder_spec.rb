describe PipelineService::MessageBuilder do
  let(:message_class_instance) do
    double('MessageClassInstance',
      noun: 'example',
      identifiers: {id: 1},
      data: {some: 'data'},
      meta: {
        source: 'canvas',
        domain_name: 'someschool.com'
      }
    )
  end

  subject do described_class.new(
    id: 1,
    noun: 'example',
    data: object,
    domain_name: 'someschool.com',
    message_class: double("message_class", new: message_class_instance)
  )
  end

  let(:object) { double("object", id: 1, changes: {}) }
  let(:message) { subject.build }

  describe "#message" do
    it '[:noun]' do
      expect(message.noun).to eq('example')
    end

    describe '[:meta]' do
      let!(:meta) do
        message.meta
      end

      it '[:domain_name]' do
        expect(meta[:domain_name]).to eq 'someschool.com'
      end

      it '[:source]' do
        expect(meta[:source]).to eq 'canvas'
      end
    end

    it '[:data]' do
      expect(message.data).to be_present
    end

    it '[:identifiers]' do
      expect(message.identifiers).to eq :id => 1
    end
  end


end
