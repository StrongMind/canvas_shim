describe PipelineService::API::Publish do
  # let(:serializer_instance) { double('serializer_instance', call: nil) }
  # let(:pipeline_serializer) { double('serializer_class', new: serializer_instance) }
  let(:serializer_fetcher)  { double('fetcher') }
  let(:submission)          { double('submission', id: 1, class: 'Submission', assignment: double('assignment')) }
  let(:command_instance)    { double('command_class', call: nil) }
  let(:command_class)       { double('command_class', new: command_instance) }

  subject do
    described_class.new(
      submission,
      command_class: command_class
    )
  end

  describe '#call' do
    it 'enqueues' do
      expect(command_instance).to receive(:call)
      subject.call
    end
  end
end
