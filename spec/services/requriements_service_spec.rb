describe RequirementsService do
  subject { described_class }
  let(:context_module) { double('context_module') }
  let(:command_class) { RequirementsService::Commands::ApplyMinimumScores }
  let(:command_instance) { double('command instance') }

  before do
    allow(command_class).to receive(:new).and_return(command_instance)
    allow(command_instance).to receive(:call)
  end
  
  describe '#apply_minimum_scores' do
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
end