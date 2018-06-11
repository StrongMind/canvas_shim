describe PipelineService::API::Publish do
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

  describe '#call' do
    it 'enqueue' do
      expect(queue).to receive(:enqueue).with(subject)
      subject.call
    end
  end
end
