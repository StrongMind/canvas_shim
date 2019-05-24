describe ContextModule do
  include_context "stubbed_network"
  context 'callbacks' do
    describe 'before_commit' do
      let!(:context_module) { ContextModule.create }
      it 'publishes to the pipeline, with an alias' do
        expect(PipelineService).to receive(:publish).with(context_module, alias: 'module')
        context_module.update(context_id: 54)
      end
    end
  end
end
