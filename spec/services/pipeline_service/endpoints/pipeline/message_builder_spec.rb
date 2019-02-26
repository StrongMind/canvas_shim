describe PipelineService::Endpoints::Pipeline::MessageBuilder do
  let(:course) { Course.create }
  let(:enrollment) { Enrollment.create(course: course) }

  before do
    allow(PipelineService::Nouns::Enrollment).to receive(:additional_identifier_fields).and_return([:course_id])
    
    ENV['CANVAS_DOMAIN'] = 'someschool.com'
    ENV['PIPELINE_ENDPOINT'] ='endpoint'
    ENV['PIPELINE_USER_NAME'] ='canvas_stage'
    ENV['PIPELINE_PASSWORD'] ='password'
  end

  subject do 
    described_class.new(
      id: 1,
      object: object
    )
  end

  let(:object) do 
    PipelineService::Nouns::Base.new(enrollment)
  end

  let(:message) do 
    subject.call 
  end

  describe "#message" do
    context 'Conversation Participant' do
      before do
        allow(PipelineService::HTTPClient).to receive(:post)
      end
      
      let(:conversation_participant) { ConversationParticipant.create }
      
      subject do
        described_class.new(
          id: conversation_participant.id,
          object: PipelineService::Nouns::Base.new(conversation_participant)
        )
      end
      
      describe '#noun' do
        it 'should use an underscored version of the noun' do
          expect(message[:noun]).to eq('conversation_participant')
        end
      end
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

      it '#status' do
        expect(meta[:status]).to eq nil
      end
    end

    it '#data' do
      class_double("PipelineService::Serializers::Enrollment", new: double('instance', call: {id: 1})).as_stubbed_const
      expect(message[:data]).to eq(:id=>1)
    end

    context "when there are additional identifiers in the serializer" do
      it 'includes the additional_identifiers in the message' do
        expect(message[:identifiers][:course_id]).to eq course.id
      end
    end

    context "when a record has been deleted" do
      let(:object) do
        PipelineService::Nouns::Base.new(enrollment)
      end

      before do
        allow(object).to receive(:destroyed?).and_return true
      end

      it '#status' do
        expect(message[:meta][:status]).to eq 'deleted'
      end
    end

    context "when a worflow state is deleted" do
      let(:object) do
        PipelineService::Nouns::Base.new(enrollment)
      end

      before do
        allow(object).to receive(:destroyed?).and_return true
      end

      it 'sets the status in meta to "deleted"' do
        expect(message[:meta][:status]).to eq('deleted')
      end
    end
  end
end
