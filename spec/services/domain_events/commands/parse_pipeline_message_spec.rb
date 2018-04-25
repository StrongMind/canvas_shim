
  describe DomainEvents::Commands::ParsePipelineMessage do
    describe '#call' do
      subject { described_class.new(message) }

      let(:listener) { DomainEvents::Listener.new() }

      let(:subscription) do
        DomainEvents::Subscription.new(listeners: [listener])
      end

      context 'listeners' do
        context 'event triggered' do
          let(:message) do
            {
              noun: 'student_enrollment',
              data: { state: 'completed' }
            }
          end

          subject do
            described_class.new(message, subscriptions: {
              graded_out: subscription
            })
          end

          it 'calls listeners' do
            expect(listener).to receive(:call)
            subject.call
          end
        end

        context 'event not triggered' do
          let(:message) { {} }

          subject do
            described_class.new(
              message,
              subscriptions: [subscription]
            )
          end

          it 'will not call if the event is not triggered' do
            expect(listener).to_not receive(:call)
            subject.call
          end
        end
      end
    end
  end
