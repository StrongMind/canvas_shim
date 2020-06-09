describe AccountAuthorizationConfig::OpenIDConnect do
  subject { described_class.new }

  describe "admin_role?" do
    context "Admin role exists in SettingsService" do
      before do
        allow(SettingsService).to receive(:global_settings).and_return(
          { "admin_roles" => "sgi-developers,cat,dog" }
        )
      end

      it "Returns truthy" do
        expect(subject.admin_role?("12345")).to be_truthy
      end
  
      context "Claims don't have role" do
        before do
          allow(subject).to receive(:claims).and_return({})
        end

        it "Returns falsy if claims don't have role" do
          expect(subject.admin_role?("12345")).to be_falsy
        end
      end
    end

    context "Admin role does not exist in SettingsService" do
      before do
        allow(SettingsService).to receive(:global_settings).and_return(
          { "admin_roles" => "pony,cat,dog" }
        )
      end

      it "Returns falsy" do
        expect(subject.admin_role?("12345")).to be_falsy
      end
    end

    context "Setting does not exist" do
      before do
        allow(SettingsService).to receive(:global_settings).and_return({})
      end

      it "Returns falsy" do
        expect(subject.admin_role?("12345")).to be_falsy
      end
    end
  end

  describe "#identity_email_address" do
    context "As Normal" do
      it "Returns an email" do
        expect(subject.identity_email_address("12345")).to eq("Andy.Rosenberg@strongmind.com")
      end
    end

    context "email does not exist" do
      before do
        allow(subject).to receive(:claims).and_return({})
      end

      it "returns nil" do
        expect(subject.identity_email_address("12345")).to be nil
      end
    end

    context "other xml configs" do
      it "returns ryan's email" do
        allow(subject).to receive(:claims).and_return({
          "http://ryankshaw.com/some/strange/xml/config/emailaddress"=>"ryankshaw@instructure.com",
        })
        expect(subject.identity_email_address("12345")).to eq "ryankshaw@instructure.com"
      end

      it "still returns ryan's email" do
        allow(subject).to receive(:claims).and_return({
          "emailaddress"=>"ryankshaw@instructure.com",
        })
        expect(subject.identity_email_address("12345")).to eq "ryankshaw@instructure.com"
      end
    end
  end
end