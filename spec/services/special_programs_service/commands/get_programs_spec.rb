describe SpecialProgramsService::Commands::GetPrograms do
  include_context "stubbed_network"
  let(:user) { User.create(name: "rks") }
  subject { described_class.new(user: user) }

  before do
    allow(subject).to receive(:partner_name).and_return("RKS SCHOOL OF FORKING")
  end

  describe "#program_applicable" do
    context "program hasn't started" do
      let(:program) do
        {
          "id" => "55555555-0000-0000-0000-000000000000",
          "programReference" => {
            "programName" => "IEP"
          },
          "educationOrganizationReference" => {
            "educationOrganizationId" => "00000000-0000-0000-0000-000000000000"
          },
          "studentReference" => {
            "studentUniqueId" => "00000000-0000-0000-0000-000000000000"
          },
          "beginDate" => "#{Date.tomorrow}",
          "endDate" => "#{2.months.from_now}"
        }
      end

      it "is not applicable" do
        expect(subject.send(:program_applicable?, program)).to be false
      end
    end
  end
end