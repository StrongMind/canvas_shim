describe PipelineService::Commands::PublishEvents do
  describe '#call' do
    subject { described_class.new(message) }

    let(:responder) {
      double(:responder, call: nil)
    }

    let(:subscription) do
      PipelineService::Events::Subscription.new(event: :graded_out, responder: responder)
    end

    context 'responders' do
      context 'event triggered' do
        let(:message) do
          {
            noun: 'student_enrollment',
            data: { enrollment_state: 'completed' }
          }
        end

        subject do
          described_class.new(message, subscriptions: [subscription])
        end

        it 'calls responders' do
          expect(responder).to receive(:call)
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
          expect(responder).to_not receive(:call)
          subject.call
        end
      end
    end
  end
end
