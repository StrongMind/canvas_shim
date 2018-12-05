describe EnrollmentsService::Commands::SetEnrollmentAssignmentDueDates do
  subject { described_class.new }

  let(:enrollment) {
    double('Enrollment')
  }

  it 'exists' do
  end

  describe "#call" do
    context 'when feature is on' do
      before do
        allow(SettingsService).to receive(:get_settings).and_return('set_individual_due_dates' => 'on')
      end
    end
    context 'when feature is off' do
      before do
        allow(SettingsService).to receive(:get_settings).and_return('set_individual_due_dates' => 'off')
      end

      it 'will not distribute the due dates' do
        expect(enrollment).to_not(receive(:update))
        subject.call
      end
    end
  end
end
