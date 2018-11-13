describe PipelineService::Events::Emitter do
  let(:object) { Enrollment.new }
  let(:serializer_class) { double(:serializer_class, new: serializer) }
  let(:serializer) { double(:serializer) }
  let(:responder_class) { double(:responder_class, new: responder) }
  let(:responder) { double(:class) }
  let(:event_class) { double('event_class') }
  let(:event) { double(:event, emit: nil) }

  before do
    allow(subject).to receive(:serializer).and_return(serializer_class)
    allow(serializer).to receive(:call).and_return({})
    allow(event_class).to receive(:new).and_return(event)
  end

  subject { described_class.new(object: object, responder: responder_class) }

  context 'graded_out_event' do
    before do
      allow(subject).to receive(:events).and_return({graded_out: event_class})
    end

    describe '#call' do
      it 'emits a graded out event' do
        expect(event).to receive(:emit)
        subject.call
      end
    end
  end

  context 'grade_changed_event' do
    let(:object) { Submission.new }
    before do
      allow(subject).to receive(:events).and_return({ grade_changed: event_class })
    end

    describe '#call' do
      it 'emits a graded out event' do
        expect(event).to receive(:emit)
        subject.call
      end
    end
  end
end
