describe AlertsService::Alerts::MaxAttemptsReachedMinScore do
  subject {
    described_class.new(
      teacher_id: 1,
      student_id: 2,
      assignment_id: 3,
      course_id: 10,
      created_at: datetime,
      updated_at: updated_datetime,
      score: 10
    )
  }

  let(:datetime) { '2019-06-13 20:53:14.153693+00:00' }
  let(:updated_datetime) { '2019-06-13 20:58:14.153693+00:00' }
  let(:json_response) { subject.as_json }

  describe '#created_at' do
    it 'is in the right format' do
      expect(subject.created_at).to eq(DateTime.parse(datetime))
    end
  end

  describe '#type' do
    it do
      expect(subject.type).to eq("max_attempts_reached_min_score")
    end
  end

  describe '#updated_at' do
    it 'is in the right format' do
      expect(subject.updated_at).to eq(DateTime.parse(updated_datetime))
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
      expect(json_response[:type]).to eq 'max_attempts_reached_min_score'
    end

    it 'description' do
      expect(json_response[:description]).to eq 'Max Attempts & Minimum Score Not Reached'
    end

    it 'score' do
      expect(json_response[:score]).to eq 10
    end

    it 'course_id' do
      expect(json_response[:course_id]).to eq 10
    end

  end

  describe '#detail' do
    subject {
      described_class.new(
        teacher_id: 1,
        student_id: 2,
        assignment_id: 3,
        created_at: datetime,
        updated_at: updated_datetime,
        score: 10.2345
      )
    }

    it 'shows the score in english' do
      expect(subject.detail).to eq "Last Score: 10.23"
    end

    it 'no value if no score' do
      subject.instance_variable_set(:@score, nil)
      expect(subject.detail).to be_nil
    end
  end
end
