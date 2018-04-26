describe PipelineService::Events::Listeners::SIS do
  let(:message) {{}}
  let(:http_client) { double('http_client') }
  before do
    ENV['SIS_ENROLLMENT_UPDATE_API_KEY'] = 'key'
    ENV['SIS_ENROLLMENT_UPDATE_ENDPOINT'] = 'endpoint'
  end

  subject do
    described_class.new(
      message: message,
      args: { http_client: http_client }

    )
  end
  describe '#call' do
    it 'posts to the http client' do
      expect(http_client).to receive(:post)
      subject.call
    end
  end
end
