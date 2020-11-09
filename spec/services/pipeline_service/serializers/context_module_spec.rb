describe PipelineService::Serializers::ContextModule do
  include_context "stubbed_network"
  let(:course) { Course.create }

  subject { described_class.new(object: noun) }

  let(:active_record_object) { ContextModule.create!(context: course) }
  let(:noun) { PipelineService::Models::Noun.new(active_record_object)}

  it 'Returns json from api modules' do
    expect(subject.call).to include( { 'id' => active_record_object.id } )
  end
end
