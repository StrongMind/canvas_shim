describe PipelineService::Events::GradeChangedEvent do
  describe '#emit' do
    let(:subscription) { double(:subscription, responder: responder) }
    let(:responder) { double(:responder, call: nil) }
    let(:object) { Submission.new }
    let(:changes) { {'score' => 10} }

    subject do
      described_class.new(
        subscription: subscription,
        resonder: responder,
        object: object,
        changes: changes
      )
    end

    context 'The grade changed' do
      it 'calls the responder' do
        expect(responder).to receive(:call)
        subject.emit
      end
    end

    context "The grade did not change" do
      let(:changes) { {} }
      it 'does not call the responder' do
        subject.emit
      end
    end
  end
end
