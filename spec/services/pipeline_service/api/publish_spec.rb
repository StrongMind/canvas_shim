describe PipelineService::API::Publish do
  let(:serializer_fetcher)  { double('fetcher') }
  let(:submission)          { double('submission', id: 1, class: 'Submission', assignment: double('assignment')) }
  let(:command_instance)    { double('command_instance', call: nil) }
  let(:command_class)       { double('command_class', new: command_instance) }
  let(:queue)               { double('queue') }

  subject do
    described_class.new(
      submission,
      command_class: command_class,
      queue: queue
    )
  end

  context 'hash object' do
    it 'works' do
      expect do
        described_class.new(
          {id: 1, last_activity_at: Time.now},
          command_class: command_class,
          queue: queue,
          noun: 'enrollment'
        )
      end.to_not raise_error
    end
  end

  describe '#call' do
    it 'enqueues' do
      expect(queue).to receive(:enqueue).with(subject)
      subject.call
    end
  end
end
