describe ExcusedService::Commands::HandleExclusions do
  subject { described_class.new(assignment: assignment, exclusions: [{ "id" => "1", "name" => "test" }]) }
  
  let(:assignment) do 
    double(
      'assignment',
      toggle_exclusion: nil,
      excused_submissions: excused_submissions
    ) 
  end

  let(:excused_submission) do
    double(
      "submission",
      user_id: 2,
    )
  end

  let(:excused_submissions) { [excused_submission] }

  describe "#call" do
    it "toggles the one in the exclusions" do
      allow(excused_submissions).to receive(:where).and_return(excused_submissions)
      expect(assignment).to receive(:toggle_exclusion).with(1, true)
      subject.call
    end

    it "unexcludes the previously excluded" do
      allow(excused_submissions).to receive(:where).and_return(excused_submissions)
      expect(assignment).to receive(:toggle_exclusion).with(2, false)
      subject.call
    end
  end
end