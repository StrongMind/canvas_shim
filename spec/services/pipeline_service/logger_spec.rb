describe PipelineService::Logger do
  describe '#call' do
    let(:message) { { foo: 'bar' } }

    subject do
      described_class.new(message: message)
    end

    it 'enqueues the post to the logger service' do
      expect(HTTParty).to receive(:post)
      subject.call
    end
  end
end
