describe AttendanceService::Commands::CheckLockout do
  include_context "stubbed_network"
  subject { described_class.new(pseudonym: identity_pseudonym) }
  let(:user) { User.create(name: "Ryan K Shaw") }
  let(:regular_pseudonym) { Pseudonym.create(user: user, unique_id: "JQUIZZLE", integration_id: "12345") }
  let(:identity_pseudonym) { Pseudonym.create(user: user, unique_id: "JQUEEZY", integration_id: SecureRandom.uuid) }
  
  before do
    allow(SettingsService).to receive(:get_settings).and_return({
      "attendance_root" => "https://google.com",
      "partner_name" => "google",
    })
  end
  
  describe "#call" do
    context "no auth" do
      it "will not work" do
        expect(subject).not_to receive(:locked_out?)
        expect(subject.call).to be false
      end
    end

    context "with auth" do
      before do
        allow(subject).to receive(:auth).and_return("A REAL API KEY")
      end

      it "will not work without a user" do
        nobody = described_class.new(pseudonym: nil)
        expect(nobody).not_to receive(:locked_out?)
        expect(nobody.call).to be false
      end

      context "no partner name" do
        before do
          allow(subject).to receive(:partner_name).and_return(nil)
        end

        it "will not work without a partner name" do
          expect(subject).not_to receive(:locked_out?)
          expect(subject.call).to be false
        end
      end

      context "no attendance root" do
        before do
          allow(subject).to receive(:attendance_root).and_return(nil)
        end

        it "will not work without a partner name" do
          expect(subject).not_to receive(:locked_out?)
          expect(subject.call).to be false
        end
      end

      context "Checkable passes" do
        before do
          allow(subject).to receive(:checkable?).and_return(true)
        end

        it "will not work without pseudonyms" do
          expect(subject).to receive(:locked_out?)
          expect(subject.call).to be_falsy
        end

        context "with regular pseudonym" do
          before do
            subject.instance_variable_set(:@pseudonym, regular_pseudonym)
          end

          it "Still returns falsy" do
            expect(subject).to receive(:locked_out?)
            expect(subject.call).to be_falsy
          end
        end

        context "with identity pseudonym" do
          before do
            allow(HTTParty).to receive(:get).and_return("isLockedOut" => true)
          end

          it "returns truthy" do
            expect(subject.call).to be_truthy
          end
        end
      end
    end
  end
end