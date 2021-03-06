describe RequirementsService::Commands::ApplyAssignmentMinScores do
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
      touch: nil
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
    allow(SettingsService).to receive(:get_settings).and_return('passing_threshold' => 70)
  end

  describe '#call' do
    it 'does not strip overrides' do
      expect(RequirementsService).to_not receive(:strip_overrides)
      expect(subject).to receive(:add_min_score_to_requirements)
      subject.call
    end

    context 'passing threshold is not set' do
      before do
        allow(SettingsService).to receive(:get_settings).and_return('passing_threshold' => 0)
      end
    
      it 'wont run if there is no threshold or no changes are needed' do
        expect(subject).to_not receive(:add_min_score_to_requirements)
        subject.call
      end
    end

    context 'force clearing threshold overrides' do
      subject { described_class.new(context_module: context_module, force: true) }
      
      before do
        allow(SettingsService).to receive(:get_settings).and_return({'passing_threshold' => 70, 'threshold_overrides' => ""})
      end

      it 'strips overrides' do
        expect(RequirementsService).to receive(:strip_overrides)
        subject.call
      end
    end

    context 'force initially false' do
      it "retains the initial setting" do
        command = described_class.new(context_module: context_module)
        command.call
        req_scores = context_module.completion_requirements.select { |req| req[:min_score] }.map { |req| req[:min_score] }
        expect(req_scores.any? && req_scores.all? { |score| score == 70.0 }).to be true
      end

      context "Score Threshold Overriden" do
        before do
          allow(SettingsService).to receive(:get_settings).and_return('passing_threshold' => 75)
          command = described_class.new(context_module: context_module, force: true)
          allow(RequirementsService).to receive(:strip_overrides).and_return(nil)
          command.call
        end

        it "overrides the previous setting" do
          req_scores = context_module.completion_requirements.select { |req| req[:min_score] }.map { |req| req[:min_score] }
          expect(req_scores.any? && req_scores.all? { |score| score == 75.0 }).to be true
        end
      end

      context 'An assignment is a unit exam' do
        before do
          allow(subject).to receive(:unit_exam?).and_call_original
          allow(subject).to receive(:unit_exam?).with({:id=>58, :type=>"must_contribute"}).and_return(true)
          subject.call
        end

        it 'Only updates one of the two submittable assignments' do
          req_scores = context_module.completion_requirements.select { |req| req[:min_score] }
          expect(req_scores.size).to eq(1)
          expect(req_scores.first[:min_score]).to eq(70)
        end
      end
    end
  end
end