describe RequirementsService::Commands::ApplyMinimumScoresToUnit do
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

  describe '#call' do
    it 'does not strip overrides' do
      expect(subject).to_not receive(:strip_overrides)
      subject.call
    end

    it 'wont run if there is no threshold or no changes are needed' do
      expect(subject).to_not receive(:add_min_score_to_requirements)
      subject.call
    end

    context 'force clearing threshold overrides' do
      subject { described_class.new(context_module: context_module, force: true) }
      
      it 'strips overrides' do
        expect(subject).to receive(:strip_overrides)
        subject.call
      end
    end
  end
end