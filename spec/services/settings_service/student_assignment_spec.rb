require ENGINE_RAILS_ROOT + 'spec/dynamodb_helper'

describe SettingsService::StudentAssignment do
  subject {
    described_class.new
  }

  let(:table_name) {'integration.example.com-student_assignment_settings'}

  context '' do
    before do
      #allow(SettingsService::Repository).to receive(:create_table)
      SettingsService::StudentAssignmentRepository.use_test_client!
    end

    xit 'blows up if canvas domain is not present' do
      expect do
        subject.create_table
      end.to raise_error("missing canvas domain!")
    end
  end

  context 'canvas domain present' do
    before do
      SettingsService.canvas_domain = 'integration.example.com'
    end

    describe '#create_table' do
      it 'creates a table' do
        expect(SettingsService::StudentAssignmentRepository).to receive(:create_table)
          .with(name: table_name)
        described_class.create_table
      end
    end

    describe '#get' do
      it 'fetches the settings for student assignment' do
        expect(SettingsService::StudentAssignmentRepository).to receive(:get).with(
          id: 1,
          table_name: table_name
        )

        described_class.get(id: 1)
      end
    end

    describe '#put' do
      let(:dynamodb) {double('dynamodb')}
      it 'calls put on the repository' do
        expect(SettingsService::StudentAssignmentRepository).to receive(:put)
        described_class.put(id: {student_id: 1, assignment_id: 2}, setting: 'max_attempts', value: 'increment')
      end
    end
  end

end
