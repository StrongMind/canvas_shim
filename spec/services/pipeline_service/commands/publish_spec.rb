describe PipelineService::Commands::Publish do
  let(:object)              { Enrollment.new }
  let(:user)                { double('user') }
  let(:test_message)        { double('message', '[]' => '') }
  let(:client_instance)     { double('pipeline_client', call: double('call_result', message: test_message)) }
  let(:client_class)        { double('pipeline_client_class', new: client_instance) }
  let(:serializer_class)    { double('serializer_class', new: serializer_instance) }
  let(:serializer_instance) { double('serializer_instance', call: nil) }
  let(:listener_instance)   { double('listener_instance') }
  let(:listener_class)      { double('listener_class', new: listener_instance) }

  subject do
    described_class.new(
      object:       object,
      user:         user,
      client:       client_class,
      serializer:   serializer_class,
      listener:     listener_class
    )
  end

  describe '#call' do
    it 'sends a message to the pipeline' do
      expect(client_instance).to receive(:call)
      subject.call
    end
  end
end
