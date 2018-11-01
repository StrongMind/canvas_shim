class Account
  def self.default
    Struct.new(:account_users).new(
      [
        Struct.new(:role, :user).new(
          Struct.new(:name).new('AccountAdmin'),
          'account admin user'
        )
      ]
    )
  end
end

describe PipelineService::Endpoints::Pipeline::MessageBuilder do
  let(:serializer_instance) { double('serializer_instance', call: nil) }
  let(:serializer_class) { double('serializer_class', new: serializer_instance) }

  before do
    ENV['CANVAS_DOMAIN'] = 'someschool.com'
    allow(PipelineService::Serializers::Fetcher)
      .to receive(:fetch)
      .and_return(serializer_class)

  end

  subject do described_class.new(
    id: 1,
    object: object
  )
  end

  let(:object) do double(
    "object",
    id: 1,
    changes: {},
    class: 'Enrollment')
  end

  let(:message) { subject.call }

  describe "#message" do
    it '#noun' do
      expect(message[:noun]).to eq('enrollment')
    end

    describe '#meta' do
      let!(:meta) do
        message[:meta]
      end

      it '#domain_name' do
        expect(meta[:domain_name]).to eq 'someschool.com'
      end

      it '#source' do
        expect(meta[:source]).to eq 'canvas'
      end
    end

    it '#data' do
      expect(message[:data]).to be_nil
    end

    it '#identifiers' do
      expect(message[:identifiers]).to eq id: 1
    end
  end

  it 'looks up the serializer' do
    expect(PipelineService::Serializers::Fetcher)
      .to receive(:fetch)
      .and_return(serializer_class)
    subject.call
  end

end
