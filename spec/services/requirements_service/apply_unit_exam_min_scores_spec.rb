describe RequirementsService::Commands::ApplyUnitExamMinScores do
  include_context 'stubbed_network'
  subject { described_class.new(context_module: context_module) }
  
  let(:course) { double('course', id: 1) }
  
  let(:context_module) do 
    double(
      'context module', 
      completion_requirements: completion_requirements,
      course: course,
      add_min_score_to_requirements: nil,
      update_column: nil,
      touch: nil,
    ) 
  end

  let(:completion_requirements) do
    [
      {:id=>53, :type=>"must_view"},
      {:id=>56, :type=>"must_submit"},
      {:id=>58, :type=>"must_contribute"}
    ]
  end

  before do
    allow(SettingsService).to receive(:get_settings).and_return('passing_exam_threshold' => 70)
    allow(subject).to receive(:unit_exam?).and_call_original
    allow(subject).to receive(:unit_exam?).with({:id=>58, :type=>"must_contribute"}).and_return(true)
    subject.call
  end

  describe "#call" do
    it "only sets the unit exam assignment" do
      req_scores = context_module.completion_requirements.select { |req| req[:min_score] }
      expect(req_scores.size).to eq(1)
      expect(req_scores.first[:min_score]).to eq(70)
    end
  end
end