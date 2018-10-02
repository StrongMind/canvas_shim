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
    before do
      allow(SettingsService).to receive(:get_settings).and_return({})
    end

    it 'enqueues' do
      expect(queue).to receive(:enqueue).with(subject, priority: 1000000)
      subject.call
    end

    it 'can be turned off' do
      allow(SettingsService).to receive(:get_settings).and_return({'disable_pipeline' => true})
      allow(queue).to receive(:enqueue)
      expect(queue).to_not receive(:enqueue)
      subject.call
    end
  end
end
