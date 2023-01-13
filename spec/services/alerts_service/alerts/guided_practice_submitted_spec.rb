describe AlertsService::Alerts::GuidedPracticeSubmitted do
  subject {
    described_class.new(
      teacher_id: 1,
      student_id: 2,
      assignment_id: 3,
      course_id: 10,
      created_at: datetime,
      updated_at: updated_datetime
    )
  }

  let(:datetime) { '2019-06-13 20:53:14.153693+00:00' }
  let(:updated_datetime) { '2019-06-13 20:58:14.153693+00:00' }
  let(:json_response) { subject.as_json }

  before do
    ENV['ALERT_SERVICE_SCHOOL_NAME'] = 'test.strongmind.com'
  end

  describe '#created_at' do
    it 'is in the right format' do
      expect(subject.created_at).to eq(DateTime.parse(datetime))
    end
  end

  describe '#type' do
    it do
      expect(subject.type).to eq("guided_practice_submitted")
    end
  end

  describe '#updated_at' do
    it 'is in the right format' do
      expect(subject.updated_at).to eq(DateTime.parse(updated_datetime))
    end
  end

  describe '#detail' do
    it 'has the correct detail' do
      expect(subject.detail).to eq "Guided Practice Submitted"
    end
  end

  describe '#as_json' do
    it 'teacher_id' do
      expect(json_response[:teacher_id]).to eq 1
    end

    it 'student_id' do
      expect(json_response[:student_id]).to eq 2
    end

    it 'assignment_id' do
      expect(json_response[:assignment_id]).to eq 3
    end

    it 'type' do
      expect(json_response[:type]).to eq 'guided_practice_submitted'
    end

    it 'description' do
      expect(json_response[:description]).to eq 'Guided Practice Submitted'
    end

    it 'course_id' do
      expect(json_response[:course_id]).to eq 10
    end

  end

end
