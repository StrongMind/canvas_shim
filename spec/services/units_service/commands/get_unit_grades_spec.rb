describe UnitsService::Commands::GetUnitGrades do
  let(:course) { Course.create(assignment_groups: []) }
  let(:pseudonym) { Pseudonym.create(sis_user_id: 1001) }
  let(:user) { User.create(pseudonym: pseudonym) }
  let(:submitted_at) { Time.now }
  let(:submission) { double('submission', submitted_at: submitted_at) }
  subject { described_class.new(course: course, student: user, submission: submission) }

  context do
    let(:query_instance) { double('query instance', query: nil) }
    let(:current_time) { Time.now }
    let(:unit) { double('unit', id: 1, created_at: current_time, position: 3 ) }
    let(:calculator_instance) { double('calculator_instance', call: { unit => 54 }) }
    
    
    before do
      allow(SettingsService).to receive(:get_settings).and_return('auto_due_dates' => nil, 'auto_enrollment_due_dates' => nil)
      @enrollment = Enrollment.create(user: user, course: course)
      ENV['CANVAS_DOMAIN'] = 'canvasdomain.com'
      allow(UnitsService::Queries::GetSubmissions).to receive(:new).and_return(query_instance)
      allow(UnitsService::GradesCalculator).to receive(:new).and_return(calculator_instance)
      allow(UnitsService::Queries::GetEnrollment).to receive(:query).and_return(@enrollment)
      allow(@enrollment).to receive(:computed_current_score).and_return(90)
    end

    it 'returns the calculator results' do
      expect(subject.call).to eq(
        course_id: course.id,
        course_score: 90,
        school_domain: "canvasdomain.com",
        student_id: user.id,
        sis_user_id: 1001,
        submitted_at: submitted_at,
        units: [{
          score: 54,
          id: unit.id,
          position: unit.position
        }]
      )
    end
  end

  context 'when missing a pseudonym' do
    let(:pseudonym) { nil }
    subject { described_class.new(course: course, student: user, submission: submission) }

    it 'returns nil for #sis_user_id' do
      expect(subject.call[:sis_user_id]).to eq(nil)
    end
  end

  context 'when pseudonym has no #sis_user_id' do
    let(:pseudonym) { Pseudonym.create(sis_user_id: nil) }
    
    it 'returns nil for #sis_user_id' do
      expect(subject.call[:sis_user_id]).to eq(nil)
    end
  end
end
