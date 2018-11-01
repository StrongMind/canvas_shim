describe PipelineService::Serializers::UnitGrades do
  subject { described_class.new(object: unit_grades)}
  let(:assignment) { double('Assignment', course: course) }
  let(:course) { double('Course') }
  let(:student) { double('Student') }
  let(:unit_grades) { double('UnitGrades', course: course, student: student) }
  let(:random_string) { rand.to_s }
  let(:command_instance) { double('CommandInstance', call: { foo: random_string }) }
  let(:course) { double('course') }
  let(:student) { double('student') }


  before do
    allow(UnitsService::Commands::GetUnitGrades).to(
      receive(:new).with(course: course, student: student).and_return(command_instance)
    )
  end

  describe 'Unit grade serializer' do
    context 'when given a submission' do
      context '#call' do
        it 'returns a hash' do
          expect(subject.call.class).to eq(Hash)
        end
        it 'returns results from the UnitService' do
          expect(subject.call[:foo]).to eq(random_string)
        end
      end
    end
  end
end
