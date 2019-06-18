describe AlertsService::Alerts::MaxAttemptsReached do
  let(:datetime) { '2019-06-13 20:53:14.153693+00:00' }
  subject { described_class.new(teacher_id: 1, student_id: 2, assignment_id: 3, created_at: datetime, updated_at: datetime) }

  describe '#created_at' do
    it 'is in the right format' do
      expect(subject.created_at).to eq(DateTime.parse(datetime))
    end
  end

  describe '#updated_at' do
    it 'is in the right format' do
      expect(subject.updated_at).to eq(DateTime.parse(datetime))
    end
  end

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