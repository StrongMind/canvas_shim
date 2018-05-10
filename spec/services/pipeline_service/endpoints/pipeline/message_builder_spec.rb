describe PipelineService::Endpoints::Pipeline::MessageBuilder do
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

  let(:serializer) { double('serializer') }

  before do
    ENV['CANVAS_DOMAIN'] = 'someschool.com'
    allow(ENV).to receive('[]').with('CANVAS_DOMAIN').and_return('someschool.com')
  end

  subject do described_class.new(
    id: 1,
    noun: 'example',
    data: object
  )
  end

  let(:object) { double("object", id: 1, changes: {}, class: 'Enrollment') }
  let(:message) { subject.call.payload }

  describe "#message" do
    it '[:noun]' do
      expect(message[:noun]).to eq('example')
    end

    describe '[:meta]' do
      let!(:meta) do
        message[:meta]
      end

      it '[:domain_name]' do
        expect(meta[:domain_name]).to eq 'someschool.com'
      end

      it '[:source]' do
        expect(meta[:source]).to eq 'canvas'
      end
    end

    it '[:data]' do
      expect(message[:data]).to be_present
    end

    it '[:identifiers]' do
      expect(message[:identifiers]).to eq id: 1
    end
  end

  it 'looks up the serializer' do
    expect(PipelineService::Serializers::Fetcher)
      .to receive(:fetch)
      .and_return(serializer)
    subject.call
  end

end
