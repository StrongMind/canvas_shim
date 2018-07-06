describe CoursesService do
  describe '#distribute_due_dates' do
    let(:instance) { double(:command_instance, call: nil) }
    let(:course)   { double(:course) }
    let(:command)  { CoursesService::Commands::DistributeDueDates }

    before do
      allow(command).to receive(:new).and_return(instance)
    end

    it 'calls the command' do
      expect(instance).to receive(:call)
      described_class.distribute_due_dates(course: course)
    end
  end
end
