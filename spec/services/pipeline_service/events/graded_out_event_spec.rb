describe PipelineService::Events::GradedOutEvent do
  let(:subscription) { double(:subscription, responder: responder) }
  let(:responder) { double(:responder, call: nil) }
  let(:object) { Enrollment.new }

  subject do
    described_class.new(
      subscription: subscription,
      object: object,
      changes: changes
    )
  end

  context "completed" do
    let(:changes) { { 'workflow_state' => [nil, 'completed']} }
    it 'calls the responder' do
      expect(responder).to receive(:call)
      subject.emit
    end
  end

  describe '#emit' do
    let(:changes) { { 'workflow_state' => []} }
    it 'does not call the responder' do
      expect(responder).to_not receive(:call)
      subject.emit
    end
  end
end
