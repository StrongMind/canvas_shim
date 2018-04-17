describe PipelineService::API::Publish do
  let(:serializer_instance) { double('serializer', call: nil) }
  let(:pipeline_serializer) { double('serializer', new: serializer_instance) }
  let(:submission)          { double('submission', pipeline_serializer: pipeline_serializer, id: 1) }
  let(:queue_client)        { double('queue_client') }
  let(:command_instance)    { double('command_class', call: nil) }
  let(:command_class)       { double('command_class', new: command_instance) }

  subject do
    described_class.new(
      submission,
      queue_client: queue_client,
      command_class: command_class
    )
  end

  describe '#call' do
    it 'enqueues' do
      expect(queue_client).to receive(:enqueue).exactly(2).times
      subject.call
    end
  end
end
