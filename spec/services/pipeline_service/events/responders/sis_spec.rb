describe PipelineService::Events::Responders::SIS do
  let(:message) {{}}
  let(:http_client) { double('http_client') }
  let(:queue) { double('queue', enqueue: nil) }
  before do
    ENV['SIS_ENROLLMENT_UPDATE_API_KEY'] = 'key'
    ENV['SIS_ENROLLMENT_UPDATE_ENDPOINT'] = 'endpoint'
  end

  subject do
    described_class.new(
      message: message,
      args: { http_client: http_client, queue: queue }

    )
  end
  describe '#call' do
    it 'posts to the http client' do
      expect(queue).to receive(:enqueue)
      subject.call
    end
  end
end
