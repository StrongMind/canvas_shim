describe PipelineService::Logger do
  describe '#call' do
    let(:message) { { foo: 'bar' } }
    let(:queue) { double('queue') }

    subject do
      described_class.new(
        message,
        queue: queue
      )
    end

    it 'enqueues the post to the logger service' do
      expect(queue).to receive(:enqueue)
      subject.call
    end
  end
end
