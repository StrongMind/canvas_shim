describe PipelineService::Logger do
  describe '#call' do
    let(:message) { { foo: 'bar' } }

    subject do
      described_class
    end

    it 'enqueues the post to the logger service' do
      expect(HTTParty).to receive(:post)
      subject.call(message)
    end
  end
end
