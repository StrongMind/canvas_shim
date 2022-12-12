describe "ContentMigration" do
  include_context "stubbed_network"
  
  before do
    allow_any_instance_of(ContentMigration).to receive(:imported?).and_return(true)
    allow_any_instance_of(ContentMigration).to receive(:complete?).and_return(true)
    allow(Rails.cache).to receive(:read).and_return(nil)
    allow(SettingsService).to receive(:get_settings).and_return({ 'third_party_imports' => true })
  end
    
  it 'will publish when saved' do
    expect(PipelineService::V2).to receive(:publish).with an_instance_of(ContentMigration)
    cm = ContentMigration.create(context_id: 1, context: Course.find_or_create_by(id: 1))
    cm.save
  end

  describe "#non_strongmind_cartrige?" do
    let(:content_migration) { ContentMigration.create(context_id: 1, context: Course.find_or_create_by(id: 1)) }
    context 'imported with strongmind cartridge' do
      before do 
        allow(Rails.cache).to receive(:read).and_return('StrongMind')
      end

      it "does not call service" do
        expect(RequirementsService).not_to receive(:set_third_party_requirements)
        content_migration.save
      end
    end

    context 'imported with third-party cartridge' do
      before do 
        allow(Rails.cache).to receive(:read).and_return(nil)
      end 

      it "calls service" do
        content_migration
        expect(RequirementsService).to receive(:set_third_party_requirements)
        content_migration.save
      end
    end
  end
end