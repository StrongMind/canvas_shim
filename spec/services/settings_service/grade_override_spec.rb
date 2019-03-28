require ENGINE_RAILS_ROOT + 'spec/dynamodb_helper'

describe SettingsService::GradeOverride do
  subject {
    described_class.new
  }

  let(:table_name) {'integration.example.com-grade_override_settings'}

  context '' do
    before do
      SettingsService::GradeOverrideRepository.use_test_client!
    end
  end

  context 'canvas domain present' do
    before do
      SettingsService.canvas_domain = 'integration.example.com'
    end

    describe '#create_table' do
      it 'creates a table' do
        expect(SettingsService::GradeOverrideRepository).to receive(:create_table).with(name: table_name)
        described_class.create_table
      end
    end

    describe '#get' do
      it 'call fetch on the repository' do
        expect(SettingsService::GradeOverrideRepository).to receive(:get).with(
          id: {
            course_id: 1,
            student_id: 1
          },
          table_name: table_name
        )

        described_class.get(id: {course_id: 1, student_id: 1})
      end
    end

    describe '#put' do
      let(:dynamodb) {double('dynamodb')}
      it 'calls put on the repository' do
        expect(SettingsService::GradeOverrideRepository).to receive(:put)
        described_class.put(id: {student_id: 1, course_id: 2}, setting: 'grade', value: 90)
      end
    end
  end

end
