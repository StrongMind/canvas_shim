describe PipelineService::Events::GradedOutEvent do
  let(:subscription) { double(:subscription, responder: responder) }
  let(:responder) { double(:responder, call: nil) }
  let(:object) { Enrollment.new }
  let(:changes) { {} }

  subject do
    described_class.new(
      subscription: subscription,
      object: object,
      changes: changes
    )
  end

  describe '#emit' do
    context "completed" do
      let(:changes) { { 'workflow_state' => [nil, 'completed']} }
      it 'calls the responder' do
        expect(responder).to receive(:call)
        subject.emit
      end
    end
    context 'not completed' do
      let(:changes) { { 'workflow_state' => []} }
      it 'does not call the responder' do
        expect(responder).to_not receive(:call)
        subject.emit
      end
    end
  end
end
