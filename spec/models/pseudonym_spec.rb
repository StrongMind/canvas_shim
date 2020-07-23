describe Pseudonym do
  include_context "stubbed_network"

  before do
    allow(SettingsService).to receive(:get_settings).and_return("identity_server_enabled" => true)
  end

  describe "#after_commit" do
    it 'does publish to the pipeline' do
      expect(PipelineService::V2).to receive(:publish)
      Pseudonym.create
    end
  end

  describe "#update_identity_mapper" do
    let(:pseudonym) { described_class.create }

    it "gets called when integration_id changes" do
      allow(pseudonym).to receive(:update_identity_mapper?)
      expect(pseudonym).to receive(:update_identity_mapper?)
      pseudonym.update(integration_id: "1234")
    end

    it "doesn't called when integration_id changes" do
      allow(pseudonym).to receive(:update_identity_mapper?)
      expect(pseudonym).not_to receive(:update_identity_mapper?)
      pseudonym.update(unique_id: "1234")
    end

    context "guard clauses" do
      before do
        allow(IdentifierMapperService::Client).to receive(:post_canvas_user_id).and_return true
        pseudonym.user = User.create
      end

      context "match uuid" do
        before do
          allow(pseudonym).to receive(:confirm_user).and_return true
        end

        it "returns nil when the integration id is not a uuid" do
          pseudonym.integration_id = "abc"
          expect(pseudonym.update_identity_mapper).to be_falsy
        end

        it "returns nil when the integration id is not a uuid" do
          pseudonym.integration_id = SecureRandom.uuid
          expect(pseudonym.update_identity_mapper).to be_truthy
        end

        context "identity not enabled" do
          before do
            allow(SettingsService).to receive(:get_settings).and_return("identity_server_enabled" => false)
            pseudonym.integration_id = SecureRandom.uuid
          end

          it "does not fire" do
            expect(pseudonym.update_identity_mapper).to be_falsy
          end
        end
      end
    end
  end
end
