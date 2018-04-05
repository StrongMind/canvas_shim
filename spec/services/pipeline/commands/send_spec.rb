class MockEnrollment
  def id;1;end
end

describe PipelineService::Commands::Send do
  let(:object)       { MockEnrollment.new }
  let(:user)         { double('user') }
  let(:api)          { double('api', messages_post: nil) }
  let(:serializer) do
    double(
      'serializer',
      call: { :id => 1, :first_name=>"Test", :last_name=>"User" }
    )
  end
  let(:test_message) { double('message') }
  let(:message_builder) { double('message_builder', build: test_message ) }
  let(:message_builder_class) { double('message_builder_class', new: message_builder) }
  let(:logger) { double('logger', log: nil) }

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
      serializer: serializer,
      queue: false,
      message_type: message_type,
      message_builder_class: message_builder_class,
      logger: logger
    )
  end

  describe '#call' do
    context 'upsert' do
      before do
        allow(subject).to receive(:build_pipeline_message) { test_message }
      end

      it 'sends a message to the pipeline' do
        expect(api).to receive(:messages_post).with(test_message)
        subject.call
      end

      it 'logs' do
        expect(logger).to receive(:log)
        subject.call
      end
    end
  end
end
