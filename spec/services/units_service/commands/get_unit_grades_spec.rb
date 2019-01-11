describe UnitsService::Commands::GetUnitGrades do
  let(:course) { double('course', assignment_groups: [], id: 1) }
  let(:pseudonym) { double('pseudonym', sis_user_id: 1001) }
  let(:user) { double('user', id: 1, pseudonym: pseudonym) }
  let(:enrollment) {double('enrollment', computed_current_score: 90)}
  let(:query_instance) { double('query instance', query: nil) }
  let(:current_time) { Time.now }
  let(:unit) { double('unit', id: 1, created_at: current_time, position: 3 ) }
  let(:calculator_instance) { double('calculator_instance', call: { unit => 54 }) }
  let(:submitted_at) { Time.now }
  let(:submission) { double('submission', submitted_at: submitted_at) }

  subject { described_class.new(course: course, student: user, submission: submission) }

  before do
    ENV['CANVAS_DOMAIN'] = 'canvasdomain.com'
    allow(UnitsService::Queries::GetSubmissions).to receive(:new).and_return(query_instance)
    allow(UnitsService::GradesCalculator).to receive(:new).and_return(calculator_instance)
    allow(Enrollment).to receive(:where).and_return([enrollment])
  end

  it 'returns the calculator results' do
    expect(subject.call).to eq(
      course_id: 1,
      course_score: 90,
      school_domain: "canvasdomain.com",
      student_id: 1,
      sis_user_id: 1001,
      submitted_at: submitted_at,
      units: [{
        :score=>54,
        id: unit.id,
        position: unit.position
      }]
    )
  end
end
