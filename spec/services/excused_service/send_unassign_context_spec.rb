describe ExcusedService::Commands::SendUnassignContext do
  include_context 'stubbed_network'

  subject do
    described_class.new(
      assignment: assignment,
      new_unassigns: [2, 3, 4], 
      previous_unassigns: [],
      grader_id: 1, 
      timestamp: timestamp
    )
  end

  let!(:timestamp) { Time.now }

  let!(:assignment) { Assignment.create }

  describe "#previous_unassign_context" do
    it "returns an object if the setting exists" do
      old_timestamp = 1.day.ago
      json = {
        old_timestamp => {
          "grader_id" => 1,
          "unassigns" => [5, 6, 7]
        }
      }.to_json

      allow(SettingsService).to receive(:get_settings).and_return({ "unassign_context" => json })
      subject.send(:previous_context=, subject.send(:previous_unassign_context))
      expect(subject.send(:previous_context)).to eq(JSON.parse(json))
    end

    it "returns a legacy unassign context if settings don't exist but there are previous unassigns" do
      allow(SettingsService).to receive(:get_settings).and_return({})
      subject.instance_variable_set(:@previous_unassigns, [4, 5, 6])
      subject.send(:previous_context=, subject.send(:previous_unassign_context))
      expect(subject.send(:previous_context)).to eq(subject.send(:legacy_unassign_context))
    end

    it "returns an empty hash with no previous unassigns and no setting" do
      allow(SettingsService).to receive(:get_settings).and_return({})
      subject.instance_variable_set(:@previous_unassigns, [])
      subject.send(:previous_context=, subject.send(:previous_unassign_context))
      expect(subject.send(:previous_context)).to eq({})
    end
  end

  describe "#clean_unassigns" do
    it "Filters reassigned students" do
      group = ["5", "6", "7", "8"]
      allow(SettingsService).to receive(:get_settings).and_return({ "unassigned_students" => "7,8" })
      subject.send(:clean_unassigns, group)
      expect(group).to eq(["7", "8"])
    end

    it "keeps unassigned students" do
      group = ["5", "6", "7", "8"]
      allow(SettingsService).to receive(:get_settings).and_return({ "unassigned_students" => "5,6,7,8" })
      subject.send(:clean_unassigns, group)
      expect(group).to eq(["5", "6", "7", "8"])
    end
  end


  describe "#clean_previous_context" do
    it "deletes element if previous unassigns are empty" do
      old_timestamp = 1.day.ago
      context = {
        old_timestamp => {
          "grader_id" => 1,
          "unassigns" => ["4","5","6"]
        }
      }
      subject.instance_variable_set(:@previous_context, context)

      allow(SettingsService).to receive(:get_settings).and_return({ "unassigned_students" => false })
      subject.send(:clean_previous_context)
      expect(subject.send(:previous_context)).to eq({})
    end
  end

  describe "#merged_unassigns" do
    before do
      old_timestamp = 1.day.ago
      context = {
        old_timestamp => {
          "grader_id" => 1,
          "unassigns" => ["4","5","6"]
        }
      }
      subject.instance_variable_set(:@previous_context, context)
    end
  
    
    it "returns a merged object" do
      expect(subject.send(:merged_unassigns)).not_to eq(subject.send(:previous_context))
      expect(subject.send(:merged_unassigns).size).to eq(2)
    end

    it "returns the previous context" do
      subject.instance_variable_set(:@new_unassigns, [])
      expect(subject.send(:merged_unassigns)).to eq(subject.send(:previous_context))
    end
  end
end