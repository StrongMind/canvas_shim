describe PipelineService::Events::Responders::SIS do
  let(:message) {{}}
  let(:object) { double(:object) }

  before do
    ENV['SIS_ENROLLMENT_UPDATE_API_KEY'] = 'key'
    ENV['SIS_ENROLLMENT_UPDATE_ENDPOINT'] = 'endpoint'
    allow(PipelineService::Events::HTTPClient).to receive(:post)
  end

  subject do
    described_class.new(
      object: object,
      message: message
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
      expect(PipelineService::Logger).to receive(:call)
      subject.call
    end
  end
end
