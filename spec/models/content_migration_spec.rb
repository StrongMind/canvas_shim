describe "ContentMigration" do
  include_context "stubbed_network"

  it 'publishes on create' do
    expect(PipelineService::V2).to receive(:publish).with an_instance_of(ContentMigration)
    ContentMigration.create
  end
end