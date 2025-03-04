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

        context "HTTP response handling" do
          let(:url) { subject.send(:full_url) }
          let(:headers) { { "CanvasAuth" => subject.send(:auth) } }

          it "is truthy with locked out status" do
            response = double(code: 200, fetch: true)
            allow(response).to receive(:try).with(:fetch, "isLockedOut", false).and_return(true)
            allow(HTTParty).to receive(:get).with(url, headers: headers).and_return(response)
            expect(subject.call).to be_truthy
          end

          it "is falsy with not locked out status" do
            response = double(code: 200, fetch: false)
            allow(response).to receive(:try).with(:fetch, "isLockedOut", false).and_return(false)
            allow(HTTParty).to receive(:get).with(url, headers: headers).and_return(response)
            expect(subject.call).to be_falsy
          end

          it "raises UnauthorizedError on 401" do
            response = double(code: 401)
            allow(HTTParty).to receive(:get).with(url, headers: headers).and_return(response)
            expect { subject.send(:locked_out?) }.to raise_error(
              AttendanceService::UnauthorizedError,
              "Unauthorized access to attendance service"
            )
          end

          it "raises UnauthorizedError on 403" do
            response = double(code: 403)
            allow(HTTParty).to receive(:get).with(url, headers: headers).and_return(response)
            expect { subject.send(:locked_out?) }.to raise_error(
              AttendanceService::UnauthorizedError,
              "Unauthorized access to attendance service"
            )
          end

          it "raises NotFoundError on 404" do
            response = double(code: 404)
            allow(HTTParty).to receive(:get).with(url, headers: headers).and_return(response)
            expect { subject.send(:locked_out?) }.to raise_error(
              AttendanceService::NotFoundError,
              "Resource not found in attendance service"
            )
          end

          it "raises ServiceError on 500" do
            response = double(code: 500)
            allow(HTTParty).to receive(:get).with(url, headers: headers).and_return(response)
            expect { subject.send(:locked_out?) }.to raise_error(
              AttendanceService::ServiceError,
              "Attendance service error: 500"
            )
          end

          it "raises UnknownError on unexpected status code" do
            response = double(code: 418) # I'm a teapot!
            allow(HTTParty).to receive(:get).with(url, headers: headers).and_return(response)
            expect { subject.send(:locked_out?) }.to raise_error(
              AttendanceService::UnknownError,
              "Unexpected response from attendance service: 418"
            )
          end
        end
      end
    end
  end
end