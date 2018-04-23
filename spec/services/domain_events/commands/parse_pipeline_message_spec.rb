describe DomainEvents::Commands::ParsePipelineMessage do
  describe '#call' do
    subject { described_class.new(message) }

    let(:listener) { double('listener') }

    context 'listeners' do
      context 'event triggered' do
        let(:message) { { noun: 'student_enrollment', data: { state: 'completed' } } }
        subject do
          described_class.new(message, subscriptions: { graded_out: { listeners: [listener]}})
        end

        it 'calls listeners' do
          expect(listener).to receive(:call)
          subject.call
        end
      end

      context 'event not triggered' do
        let(:message) { {} }

        subject do
          described_class.new(message, subscriptions: { unknown_event: { listeners: [listener]}})
        end

        it 'will not call if the event is not triggered' do
          expect(listener).to_not receive(:call)
          subject.call
        end
      end
    end
  end


end
