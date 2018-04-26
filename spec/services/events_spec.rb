describe PipelineService::Events do
  subject { described_class }
  let(:message) { {} }
  let(:command_instance) { double('command_instance', call: nil) }
  let(:command) { double(:command, new: command_instance) }

  describe '#parse_pipeline_message' do
    it 'calls the parse pipeline command' do
      expect(command_instance).to receive(:call)
      subject.parse_pipeline_message(message, command: command)
    end
  end
end
