describe "ContentMigration" do
  include_context "stubbed_network"

    it 'will publish when saved' do
      expect(PipelineService::V2).to receive(:publish).with an_instance_of(ContentMigration)
      cm = ContentMigration.create()
      cm.save
    end

end