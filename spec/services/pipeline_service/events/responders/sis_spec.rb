describe PipelineService::Events::Responders::SIS do
  let(:message) {{}}
  let(:http_client) { double('http_client') }
  let(:queue) { double('queue', enqueue: nil) }
  let(:logger_class) { double('logger_class', new: logger_instance) }
  let(:logger_instance) { double('logger_instance', call: nil) }
  let(:object) { double(:object) }

  before do
    ENV['SIS_ENROLLMENT_UPDATE_API_KEY'] = 'key'
    ENV['SIS_ENROLLMENT_UPDATE_ENDPOINT'] = 'endpoint'
    allow(PipelineService::Events::HTTPClient).to receive(:post)
  end

  subject do
    described_class.new(
      object: object,
      message: message,
      args: {
        http_client: http_client,
        queue: queue,
        logger: logger_class
      }

    )
  end
  describe '#call' do
    it 'posts to the http client' do
      expect(PipelineService::Events::HTTPClient).to receive(:post)
      subject.call
    end
  end

  context 'logging' do
    it 'logs' do
      expect(logger_instance).to receive(:call)
      subject.call
    end
  end
end
