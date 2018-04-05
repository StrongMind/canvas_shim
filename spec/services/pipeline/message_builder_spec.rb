describe PipelineService::MessageBuilder do
  subject do described_class.new(
    id: 1,
    noun_name: 'example',
    object: object,
    domain_name: 'someschool.com'
  )
  end
  let(:object) { double("object", id: 1) }

  let(:message) do
    subject.build
  end

  describe "#message" do
    it 'has a noun' do
      expect(message.noun).to eq('example')
    end

    it 'has metadata' do
      expect(message.meta).to eq({:source=>"canvas", :domain_name=>"someschool.com"})
    end

    it 'has data' do
      expect(message.data).to be_present
    end

    it 'has identifiers' do
      expect(message.identifiers).to eq :id => 1
    end
  end

  describe '#meta' do
    let!(:meta) do
      message.meta
    end

    it 'has the domain name of the school' do
      expect(meta[:domain_name]).to eq 'someschool.com'
    end

    it 'has the source of the app' do
      expect(meta[:source]).to eq 'canvas'
    end
  end
end
