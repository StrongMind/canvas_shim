describe RequirementsService do
  subject { described_class }
  include_context 'stubbed_network'

  let(:context_module) { double('context_module') }
  let(:requirements) { double('requirements') }
  let(:content_tag) { double('content_tag') }
  let(:command_instance) { double('command instance') }
  let(:assignment_group_names) { ["assignment", "checkpoint", "close_reading_project", "discussion", "exam", "final_exam", "pretest", "project", "workbook"] }

  before do
    allow(command_class).to receive(:new).and_return(command_instance)
    allow(command_instance).to receive(:call)
  end

  describe '#apply_minimum_scores' do
    let(:command_class) { RequirementsService::Commands::ApplyAssignmentGroupMinScores }

    it 'Calls the command object' do
      expect(command_instance).to receive(:call)
      subject.apply_assignment_group_min_scores(context_module: context_module, assignment_group_names: assignment_group_names)
    end

    context "stripping overrides" do
      it 'accepts a strip overrides parameter' do
        expect(command_class).to receive(:new).with(context_module: context_module, force: true, assignment_group_name: assignment_group_names[0])
        expect(command_class).to receive(:new).with(context_module: context_module, force: true, assignment_group_name: assignment_group_names[1])
        expect(command_class).to receive(:new).with(context_module: context_module, force: true, assignment_group_name: assignment_group_names[2])
        expect(command_class).to receive(:new).with(context_module: context_module, force: true, assignment_group_name: assignment_group_names[3])
        expect(command_class).to receive(:new).with(context_module: context_module, force: true, assignment_group_name: assignment_group_names[4])
        expect(command_class).to receive(:new).with(context_module: context_module, force: true, assignment_group_name: assignment_group_names[5])
        expect(command_class).to receive(:new).with(context_module: context_module, force: true, assignment_group_name: assignment_group_names[6])
        expect(command_class).to receive(:new).with(context_module: context_module, force: true, assignment_group_name: assignment_group_names[7])
        expect(command_class).to receive(:new).with(context_module: context_module, force: true, assignment_group_name: assignment_group_names[8])

        subject.apply_assignment_group_min_scores(context_module: context_module, force: true, assignment_group_names: assignment_group_names)
      end
    end
  end

  describe '#set_passing_threshold' do
    let(:command_class) { RequirementsService::Commands::SetPassingThreshold }

    it 'Calls the command object' do
      expect(command_instance).to receive(:call)
      subject.set_passing_threshold(type: 'school', threshold: 70, edited: 'true', assignment_group_name: 'workbook')
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

  describe '#add_unit_item_with_passing_threshold' do
    let(:command_class) { RequirementsService::Commands::AddUnitItemWithPassingThreshold }

    it 'Calls the command object' do
      expect(command_instance).to receive(:call)
      subject.add_unit_item_with_passing_threshold(context_module: context_module, content_tag: content_tag, assignment_group_name: nil)
    end
  end

  describe '#apply_minimum_scores' do
    let(:command_class) { RequirementsService::Commands::DefaultThirdPartyRequirements }
    let(:course) { Course.create }

    before do
      5.times { course.context_modules << ContextModule.create }
    end

    it 'Calls the command object' do
      allow_any_instance_of(ContextModule).to receive(:completion_requirements).and_return([])
      expect(command_instance).to receive(:call)
      subject.set_third_party_requirements(course: course)
    end

    it "does not work when the context modules have completion requirements" do
      allow_any_instance_of(ContextModule).to receive(:completion_requirements).and_return([1])
      expect(command_instance).not_to receive(:call)
      subject.set_third_party_requirements(course: course)
    end
  end
end
