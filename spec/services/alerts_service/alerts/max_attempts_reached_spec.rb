describe AlertsService::Alerts::MaxAttemptsReached do
  
  subject { described_class.new(teacher_id: 1, student_id: 2, assignment_id: 3) }

  describe '#as_json' do
    it 'teacher_id' do
      expect(subject.as_json[:teacher_id]).to eq 1
    end

    it 'student_id' do
      expect(subject.as_json[:student_id]).to eq 2
    end

    it 'assignment_id' do
      expect(subject.as_json[:assignment_id]).to eq 3
    end

    it 'type' do
      expect(subject.as_json[:type]).to eq 'Max Attempts Reached'
    end
  end
end