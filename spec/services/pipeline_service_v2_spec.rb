  describe PipelineService::V2 do
  let(:ar_object) { double('ar object')}
  let(:command) { double('command', call: nil) }
  let(:command_class) { PipelineService::V2::API::Publish }

  describe '#publish' do
    before do
      class_double("Sentry").as_stubbed_const
    end

    it 'calls the api' do
      expect(command_class).to receive(:new)
        .with(ar_object)
        .and_return(command)
      described_class.publish(ar_object)
    end

    context 'error publishing' do
      before do
        allow(command_class).to receive(:new).and_raise('boom')
      end

      it 'supresses the error andreports to sentry' do
        expect(Sentry).to receive(:capture_exception)
        described_class.publish(ar_object)
      end
    end
  end
end

