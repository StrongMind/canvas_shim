describe PipelineService::Serializers::Assignment do
  include_context "stubbed_network"

  subject { described_class.new(object: noun) }

  let(:course) { Course.create!() }
  let(:active_record_object) { Assignment.create!(course: course) }
  let(:noun) { PipelineService::Models::Noun.new(active_record_object)}

  it 'Returns json from api modules' do
    expect(subject.call).to include( { 'id' => active_record_object.id } )
  end
end
