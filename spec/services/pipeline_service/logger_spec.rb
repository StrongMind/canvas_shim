describe PipelineService::Logger do
  describe '#call' do
    let(:message) { double('message') }
    let(:http_client) { double('http_client') }

    subject { described_class.new(message, http_client: http_client) }

    it 'posts to an http library' do
      expect(http_client).to receive(:post)
      subject.call
    end
  end
end
