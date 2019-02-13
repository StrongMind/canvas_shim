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
    allow(subject).to receive(:events).and_return({ grade_changed: event_class })
  end

  subject { described_class.new(object: PipelineService::Models::Noun.new(object), responder: responder_class) }

  context 'unhandled noun' do
    class UnhandledNoun
      def id
        1
      end

      def destroyed?
        false
      end
    end

    let(:object) { PipelineService::Models::Noun.new(UnhandledNoun.new) }
    before do
      allow(subject).to receive(:serializer).and_return(nil)
    end

    describe '#call' do
      it 'does not emit an event' do
        expect(event).to_not receive(:emit)
        subject.call
      end
    end
  end

  context 'graded_out_event' do
    describe '#call' do
      it 'emits an event' do
        expect(event).to receive(:emit)
        subject.call
      end
    end
  end

  context 'grade_changed_event' do
    describe '#call' do
      it 'emits an event' do
        expect(event).to receive(:emit)
        subject.call
      end
    end
  end
end
