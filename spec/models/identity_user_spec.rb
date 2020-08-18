describe User do
  include_context 'stubbed_network'
  let(:subject) { User.new(run_identity_validations: "create", identity_email: "ryankshaw@example.com", account: account) }
  let(:account) { Account.create }
  let(:success_response) do 
    instance_double(HTTParty::Response, parsed_response: JSON.parse(success_response_body), success?: true)
  end

  before do
    allow(subject).to receive(:identity_client_credentials).and_return("12345")
    allow(subject).to receive(:identity_domain).and_return("example.com")
    allow(SettingsService).to receive(:update_settings)
  end
  
  describe "#access_token" do
    let(:access_token) { "eiug2fgiuqefgiuqfe" }

    let(:success_response_body) do
      {
        "access_token" => access_token,
        "expires_in" => 3600,
        "token_type" => "Bearer",
        "scope" => "identity_server_api.full_access"
      }.to_json
    end

    context "no credentials" do
      before do
        allow(subject).to receive(:identity_client_credentials).and_return(nil)
      end
      
      it "does not send" do
        expect(HTTParty).not_to receive(:post)
        subject.send(:access_token)
      end
    end
    
    context "successful response" do
      before do
        allow(HTTParty).to receive(:post).and_return(success_response)
      end

      it "creates an access token" do
        expect(subject.send(:access_token)).to eq(access_token)
      end
    end
  end

  describe "#validate_identity_creation" do
    it "runs create validations" do
      expect(subject).to receive(:validate_identity_creation)
      subject.save
    end

    it "does not run identity validations" do
      subject.run_identity_validations = "nope"
      expect(subject).not_to receive(:validate_identity_creation)
      subject.save
    end
  end

  describe '#create' do
    let(:success_response_body) do
      {
        "id": "273f2717-134a-4ff3-9a23-c00a6987510c",
        "username": "name namely",
        "email": "email@example.com",
        "firstName": nil,
        "lastName": nil,
        "dateOfBirth": nil,
        "timeZone": nil,
        "sendPasswordResetEmail": true
      }.to_json
    end

    before do
      allow(subject).to receive(:access_token).and_return("eiug2fgiuqefgiuqfe")
      allow(HTTParty).to receive(:post).and_return(success_response)
    end

    it "creates" do
      expect(subject.save).to eq(true)
    end

    context "registered user" do
      before do
        allow(subject).to receive(:identity_enabled).and_return(true)
      end

      it "adds a workflow state of registered" do
        subject.save
        expect(subject.reload.workflow_state).to eq("registered")
      end
    end

    it "creates an identity pseudonym" do
      subject.save
      pseudo = subject.pseudonyms.reload.last
      expect(pseudo.integration_id).to eq("273f2717-134a-4ff3-9a23-c00a6987510c")
      expect(pseudo.unique_id).to eq(subject.identity_username)
      expect(pseudo.new_record?).to be false
    end

    context "no access token" do
      before do
        allow(subject).to receive(:access_token).and_return(nil)
      end

      it "does not create" do
        expect(subject.save).to eq(false)
        expect(subject.errors["name"]).to eq ["Identity Server: Access Token Not Granted"]
      end
    end

    context "Failed response" do
      let(:fail_response) do 
        instance_double(HTTParty::Response, parsed_response: JSON.parse(success_response_body), success?: false)
      end

      let(:fail_response_body) do
        { "error" => { "message" => "Bad Request" } }
      end
      
      before do
        allow(HTTParty).to receive(:post).and_return(fail_response)
      end

      it "does not create" do
        expect(subject.save).to eq(false)
        expect(subject.errors["name"]).to eq ["Identity Server: User Not Created"]
      end
    end

    context "Failed email validation" do
      let(:fail_user) { User.new(run_identity_validations: "create", identity_email: nil) }

      it "does not save" do
        expect(fail_user.save).to eq(false)
        expect(fail_user.errors["email"]).to eq ["Identity Server: Email Invalid"]
      end
    end
  end

  describe "#save_with_identity_server_create" do
    let(:fail_user) { User.new(run_identity_validations: "create") }

    it "fails validation with bang" do
      expect { fail_user.save_with_identity_server_create("bademail", force: true) }.to raise_error ActiveRecord::RecordInvalid
    end

    it "fails validation without bang" do
      expect { fail_user.save_with_identity_server_create("bademail", force: false) }.not_to raise_error
      expect(fail_user.errors["email"]).to eq ["Identity Server: Email Invalid"]
    end
  end

  describe "#check_identity_duplicate" do
    let(:user) { User.new(name: "dupe dude", run_identity_validations: "create") }

    it "fails without identity on" do
      allow(user).to receive(:identity_enabled).and_return(false)
      expect(user).not_to receive(:check_identity_duplicate)
      user.save_with_identity_server_create("hello@example.com")
    end

    it "fails without an identity email" do
      allow(user).to receive(:identity_enabled).and_return(true)
      expect(user).not_to receive(:check_identity_duplicate)
      user.identity_email = nil
      user.save_with_identity_server_create(nil)
    end

    it "fails if a user already exists" do
      allow(user).to receive(:identity_enabled).and_return(true)
      allow(user).to receive(:name).and_return("dupe dude")
      dupe = User.create!(name: "dupe dude")
      dupe.communication_channels.create!(path: "hello@example.com", path_type: "email")
      user.save_with_identity_server_create("hello@example.com")
      expect(user.errors["name"]).to include("Identity Server: User Already Exists")
    end
  end

  describe "#save_with_or_without_identity_create" do
    before do
      allow(subject).to receive(:save)
      allow(subject).to receive(:save!)
    end

    it "runs save without any args" do
      allow(subject).to receive(:identity_enabled).and_return(false)
      expect(subject).not_to receive(:save_with_identity_server_create)
      expect(subject).to receive(:save)
      subject.save_with_or_without_identity_create
    end

    it "runs save! when forced" do
      allow(subject).to receive(:identity_enabled).and_return(false)
      expect(subject).not_to receive(:save_with_identity_server_create)
      expect(subject).to receive(:save!)
      subject.save_with_or_without_identity_create("email", force: true)
    end

    it "runs save_with_identity_create with args" do
      allow(subject).to receive(:identity_enabled).and_return(true)
      expect(subject).to receive(:save_with_identity_server_create)
      subject.save_with_or_without_identity_create("ryankshaw@example.com")
    end

    it "runs save when provisioned is true" do
      allow(subject).to receive(:identity_enabled).and_return(true)
      expect(subject).not_to receive(:save_with_identity_server_create)
      expect(subject).to receive(:save)
      subject.save_with_or_without_identity_create(nil, provisioned: true)
    end
  end

  describe "::find_by_sis_user_id" do
    let(:user) { User.create }
    let(:pseudonym) { Pseudonym.create(user: user) }

    before do
      allow(User).to receive(:active).and_return(User.all)
    end
    
    context "with SIS ID" do
      before do
        pseudonym.update(sis_user_id: "12345")
      end

      context "with active workflow state" do
        before do
          pseudonym.update(workflow_state: "active")
        end

        it "finds the user if the workflow state is active" do
          expect(User.find_by_sis_user_id("12345")).to be_truthy
        end

        it "finds the user if there are multiple pseudonyms" do
          user.pseudonyms.create(workflow_state: "deleted")
          expect(User.find_by_sis_user_id("12345")).to be_truthy
        end

        it "does not find the user if the id does not match" do
          expect(User.find_by_sis_user_id("00000")).to be_falsy
        end
      end

      it "does not find the user if the workflow state is not active" do
        pseudonym.update(workflow_state: "deleted")
        expect(User.find_by_sis_user_id("12345")).to be_falsy
      end
    end
  end

  describe "#already_provisioned_in_identity?" do
    let(:user) { User.create }
    let!(:pseudonym) { user.pseudonyms.create(integration_id: SecureRandom.uuid) }

    let(:success_response) { {"username" => true} }

    before do
      allow(success_response).to receive(:success?).and_return(true)
      allow_any_instance_of(Pseudonym).to receive(:confirm_user).and_return(success_response)
    end

    it "works with a provisioned identity" do
      expect(user.reload.already_provisioned_in_identity?).to be(true)
    end

    it "works with multiple logins" do
      user.pseudonyms.create!(integration_id: "12345")
      expect(user.reload.already_provisioned_in_identity?).to be(true)
    end

    context "identity id but not provisioned" do
      before do
        allow(success_response).to receive(:success?).and_return(false)
      end

      it "does not work" do
        expect(user.reload.already_provisioned_in_identity?).to be(false)
      end
    end

    context "no identity integration ids" do
      before do
        user.pseudonyms.destroy_all
        user.pseudonyms.create!(integration_id: "12345")
      end

      it "does not work" do
        expect(user.reload.already_provisioned_in_identity?).to be(false)
      end
    end
  end
end