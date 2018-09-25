describe GradesService::Commands::ZeroOutAssignmentGradesRollback do
  subject {described_class.new}

  describe '#call' do
    before do
      allow(SettingsService).to receive(:query).with('zero_grader_audit')
    end

    it 'works' do
      subject.call!
    end

    it 'gets modified submissions' do
      expect(SettingsService).to receive(:query).with('zero_grader_audit')
      subject.call!
    end
  end
end
