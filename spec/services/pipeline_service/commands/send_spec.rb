class MockSerializer
  def initialize(object)
  end

  def call
  end
end

class MockEnrollment
  def id;1;end

  def pipeline_serializer
    MockSerializer
  end
end

describe PipelineService::Commands::Send do
  let(:object)          { MockEnrollment.new }
  let(:user)            { double('user') }
  let(:api)             { double('api', messages_post: nil) }
  let(:test_message)    { double('message') }
  let(:message_builder) { double('message_builder', build: test_message ) }
  let(:message_builder_class) { double('message_builder_class', new: message_builder) }
  let(:client)          { double('pipeline_client', call: double('call_result', message: test_message)) }
  let(:logger)          { double('logger', log: nil) }

  subject do
    described_class.new(
      object: object,
      user: user,
      message_api: api,
      queue: false,
      message_builder_class: message_builder_class,
      client: client,
      logger: logger
    )
  end

  describe '#call' do
    context 'upsert' do
      it 'sends a message to the pipeline' do
        expect(client).to receive(:call)
        subject.call
      end

      # it 'logs' do
      #   expect(logger).to receive(:log)
      #   subject.call
      # end

      it 'looks up the serializer' do
        expect(subject.call.serializer).to be_a(MockSerializer)
      end
    end
  end
end
