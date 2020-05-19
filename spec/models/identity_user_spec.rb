describe User do
  include_context 'stubbed_network'
  let(:subject) { User.new(run_identity_validations: "create", identity_email: "ryankshaw@example.com") }
  let(:success_response) do 
    instance_double(HTTParty::Response, parsed_response: JSON.parse(success_response_body), success?: true)
  end

  before do
    allow(subject).to receive(:identity_client_credentials).and_return("12345")
    allow(subject).to receive(:identity_domain).and_return("example.com")
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
  end
end