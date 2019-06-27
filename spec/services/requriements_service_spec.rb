describe RequirementsService do
  subject { described_class }
  let(:context_module) { double('context_module') }
  let(:requirements) { double('requirements') }
  let(:content_tag) { double('content_tag') }
  let(:command_instance) { double('command instance') }

  before do
    allow(command_class).to receive(:new).and_return(command_instance)
    allow(command_instance).to receive(:call)
  end
  
  describe '#apply_minimum_scores' do
    let(:command_class) { RequirementsService::Commands::ApplyMinimumScores }

    it 'Calls the command object' do
      expect(command_instance).to receive(:call)
      subject.apply_minimum_scores(context_module: context_module)
    end

    context "stripping overrides" do
      it 'accepts a strip overrides parameter' do
        expect(command_class).to receive(:new).with(context_module: context_module, force: true)
        subject.apply_minimum_scores(context_module: context_module, force: true)  
      end
    end
  end

  describe '#set_passing_threshold' do
    let(:command_class) { RequirementsService::Commands::SetPassingThreshold }

    it 'Calls the command object' do
      expect(command_instance).to receive(:call)
      subject.set_passing_threshold(type: 'school', threshold: 70, edited: 'true')
    end
  end

  describe '#set_threshold_permissions' do
    let(:command_class) { RequirementsService::Commands::SetThresholdPermissions }

    it 'Calls the command object' do
      expect(command_instance).to receive(:call)
      subject.set_threshold_permissions(course_thresholds: true, post_enrollment: true, module_editing: true)
    end
  end

  describe '#add_threshold_overrides' do
    let(:command_class) { RequirementsService::Commands::AddThresholdOverrides }

    it 'Calls the command object' do
      expect(command_instance).to receive(:call)
      subject.add_threshold_overrides(context_module: context_module, requirements: requirements)
    end
  end

  describe '#add_unit_item_with_min_score' do
    let(:command_class) { RequirementsService::Commands::AddUnitItemWithMinScore }

    it 'Calls the command object' do
      expect(command_instance).to receive(:call)
      subject.add_unit_item_with_min_score(context_module: context_module, content_tag: content_tag)
    end
  end
end