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
  let(:serializer_instance) { double('serializer_instance', call: {id: 1}) }
  let(:serializer_class) { double('serializer_class', new: serializer_instance) }

  before do
    class_double("PipelineService::Serializers::Enrollment", new: serializer_instance).as_stubbed_const
    ENV['CANVAS_DOMAIN'] = 'someschool.com'
  end

  subject do 
    described_class.new(
      id: 1,
      object: object
    )
  end

  let(:object) do 
    PipelineService::Models::Noun.new(Enrollment.new)
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
      expect(message[:data]).to eq(:id=>1)
    end

    context "when there are additional identifiers in the serializer" do
      let(:serializer_instance) do
        double('serializer_instance', call: nil, additional_identifiers: { course_id: 2 })
      end

      it 'includes the additional_identifiers in the message' do
        expect(message[:identifiers][:course_id]).to eq 2
      end
    end

    context "when a record has been deleted" do
      let(:object) do
        PipelineService::Models::Noun.new(Enrollment.new)
      end

      before do
        allow(object).to receive(:destroyed?).and_return true
      end

      it 'sends an empty data field in the message' do
        expect(message[:data]).to eq({})
      end
    end

    context "when a worflow state is deleted" do
      let(:object) do
        PipelineService::Models::Noun.new(Enrollment.new)
      end

      before do
        allow(object).to receive(:destroyed?).and_return true
      end

      it 'sends an empty data field in the message' do
        expect(message[:data]).to eq({})
      end
    end
  end
end
