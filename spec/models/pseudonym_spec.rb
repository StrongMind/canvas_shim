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
        let(:success_response) { {"username" => true} }

        before do
          allow(success_response).to receive(:success?).and_return(true)
          allow(pseudonym).to receive(:confirm_user).and_return(success_response)
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
            allow(pseudonym.user).to receive(:identity_enabled).and_return(false)
            pseudonym.integration_id = SecureRandom.uuid
          end

          it "does not fire" do
            expect(pseudonym.update_identity_mapper).to be_falsy
          end
        end
      end
    end
  end

  describe "#get_identity_username?" do
    let(:username) { "ryankshaw_8qj1" }
    let(:pseudonym) { described_class.create }

    context "Successful call" do
      before do
        allow(pseudonym).to receive(:confirm_user).and_return({"username" => username})
      end

      it "works correctly" do
        pseudonym.get_identity_username?
        expect(pseudonym.unique_id).to eq(username)
      end
    end

    context "non unicode" do
      before do
        allow(pseudonym).to receive(:confirm_user).and_return({"username" => username + "\xa0" + "valid"})
      end

      it "parameterizes the unicode" do
        pseudonym.get_identity_username?
        expect(pseudonym.unique_id).to eq("#{username} valid")
      end
    end

    context "Unsuccessful call" do
      let(:bad_response) { { "error": "bad request" } }

      before do
        allow(bad_response).to receive(:code).and_return(400)
        allow(pseudonym).to receive(:confirm_user).and_return(bad_response)
        pseudonym.unique_id = "hereismyuniqueid"
      end

      it "works incorrectly" do
        pseudonym.get_identity_username?
        expect(pseudonym.unique_id).to eq(nil)
        expect(pseudonym.errors["unique_id"]).to include("Incorrect Identity. Identity Server Responded with 400.")
      end
    end
  end

  context "when integration_id is nil" do
    let(:pseudonym) { described_class.create }
    it "is valid" do
      pseudonym.user = User.create!
      pseudonym.integration_id = nil
      expect(pseudonym.save).to be true
    end
  end
end
