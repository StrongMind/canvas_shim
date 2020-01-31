describe "ContentMigration" do
  include_context "stubbed_network"

  context "when workflow state hasn't changed to imported" do
    it 'wont publish' do
      expect(PipelineService::V2).to_not receive(:publish).with an_instance_of(ContentMigration)
      ContentMigration.create
    end
  end

  context "when workflow state changes to imported" do
    it 'will publish' do
      expect(PipelineService::V2).to receive(:publish).with an_instance_of(ContentMigration)
      cm = ContentMigration.create(workflow_state: 'importing')
      cm.save
      cm.update(workflow_state: 'imported')
    end
  end

end