describe PipelineService::Events::Emitter do
  let(:event_class) { double('event_class')}
  let(:object) { Enrollment.new }
  let(:serializer_class) { double(:serializer_class, new: serializer) }
  let(:serializer) { double(:serializer) }
  let(:responder_class) { double(:responder_class, new: responder) }
  let(:responder) { double(:class) }
  let(:event) { double(:event, emit: nil) }

  before do
    allow(subject).to receive(:event).and_return({ graded_out: event_class })
    allow(subject).to receive(:serializer).and_return(serializer_class)
    allow(serializer).to receive(:call).and_return({})
  end

  subject { described_class.new(object: object, responder: responder_class) }
  describe '#call' do
    it 'emits a graded out event' do
      expect(event_class).to receive(:new).and_return(event)
      subject.call
    end
  end
end
