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

  def intitialize(object:)
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

  before do
    ENV['PIPELINE_ENDPOINT'] = 'https://example.com'
    ENV['PIPELINE_USER_NAME'] = 'example_user'
    ENV['PIPELINE_PASSWORD'] = 'example_password'
    ENV['CANVAS_DOMAIN'] = 'someschool.com'
  end

  subject do
    build_send_command
  end

  def build_send_command(message_type: :upserted)
    described_class.new(
      object: object,
      user: user,
      message_api: api,
      queue: false,
      message_type: message_type,
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
