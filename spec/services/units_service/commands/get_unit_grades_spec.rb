describe UnitsService::Commands::GetUnitGrades do
  let(:course) { double('course', assignment_groups: [], id: 1) }
  let(:user) { double('user', id: 1) }
  let(:query_instance) { double('query instance', query: nil) }
  let(:current_time) { Time.now }
  let(:unit) { double('unit', id: 1, created_at: current_time, position: 3 ) }
  let(:calculator_instance) { double('calculator_instance', call: { unit => 54 }) }

  subject { described_class.new(course: course, student: user) }

  before do
    ENV['CANVAS_DOMAIN'] = 'canvasdomain.com'
    allow(UnitsService::Queries::GetSubmissions).to receive(:new).and_return(query_instance)
    allow(UnitsService::GradesCalculator).to receive(:new).and_return(calculator_instance)
  end

  it 'returns the calculator results' do
    expect(subject.call).to eq(
      course_id: 1,
      school_domain: "canvasdomain.com",
      student_id: 1,
      units: [{
        :score=>54,
        id: unit.id,
        created_at: unit.created_at,
        position: unit.position
      }]
    )
  end
end
