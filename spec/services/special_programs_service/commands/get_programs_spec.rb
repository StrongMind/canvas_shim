def create_program(start_date, end_date)
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
    "beginDate" => start_date,
    "endDate" => end_date
  }
end


describe SpecialProgramsService::Commands::GetPrograms do
  include_context "stubbed_network"
  let(:user) { User.create(name: "rks") }
  subject { described_class.new(user: user) }

  before do
    allow(subject).to receive(:partner_name).and_return("RKS SCHOOL OF FORKING")
  end

  describe "#program_applicable" do
    context "program hasn't started" do
      let(:program) { create_program("#{Date.tomorrow}", "#{2.months.from_now}") }

      it "is not applicable" do
        expect(subject.send(:program_applicable?, program)).to be false
      end
    end

    context "program has ended" do
      let(:program) { create_program("#{1.month.ago}", "#{Date.yesterday}") }
  
      it "is not applicable" do
        expect(subject.send(:program_applicable?, program)).to be false
      end
    end
  end

  context "program has no start or end date" do
    let(:program) { create_program(nil, nil) }

    it "is applicable" do
      expect(subject.send(:program_applicable?, program)).to be true
    end
  end

  context "program has no start date and has end date" do
    let(:program) { create_program(nil, "#{Date.tomorrow}") }

    it "is applicable" do
      expect(subject.send(:program_applicable?, program)).to be true
    end

    context "end date before now" do
      let(:program) { create_program(nil, "#{Date.yesterday}") }

      it "is not applicable" do
        expect(subject.send(:program_applicable?, program)).to be false
      end
    end
  end

  context "program has no end date and has start date" do
    let(:program) { create_program("#{Date.yesterday}", nil) }

    it "is applicable" do
      expect(subject.send(:program_applicable?, program)).to be true
    end

    context "end date before now" do
      let(:program) { create_program("#{Date.tomorrow}", nil) }

      it "is not applicable" do
        expect(subject.send(:program_applicable?, program)).to be false
      end
    end
  end
end