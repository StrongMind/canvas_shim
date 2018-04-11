describe PipelineService::API::Publish do
  let(:serializer_instance) { double('serializer', call: nil) }
  let(:submission) do
    double(
      'submission',
      pipeline_serializer: double('serializer', new: serializer_instance),
      id: 1
    )
  end
  let(:queue_client) { double('queue_client') }
  let(:command_instance) { double('command_class', call: nil) }
  let(:command_class) { double('command_class', new: command_instance) }

  subject do
    described_class.new(
      submission,
      queue_client: queue_client,
      command_class: command_class
    )
  end

  before do
    ENV['PIPELINE_ENDPOINT'] = 'https://example.com'
    ENV['PIPELINE_USER_NAME'] = 'example_user'
    ENV['PIPELINE_PASSWORD'] = 'example_password'
    ENV['CANVAS_DOMAIN'] = 'someschool.com'
  end

  describe '#call' do
    context 'queued' do
      it 'enqueues' do
        expect(queue_client).to receive(:enqueue)
        subject.call
      end
    end
    context 'inline' do
      before do
        @skip_value = ENV['PIPELINE_SKIP_QUEUE']
        ENV['PIPELINE_SKIP_QUEUE'] = 'true'
      end
      after do
        ENV['PIPELINE_SKIP_QUEUE'] = @skip_value
      end

      it 'runs inline' do
        expect(queue_client).to_not receive(:enqueue)
        subject.call
      end
    end
  end
end
