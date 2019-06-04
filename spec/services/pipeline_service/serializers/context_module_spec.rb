describe PipelineService::Serializers::ContextModule do
  include_context "stubbed_network"
  let(:course) { Course.create }

  subject { described_class.new(object: noun) }

  before do
    allow(PipelineService::HTTPClient).to receive(:get).and_return(
      double('response', parsed_response: { "id" => active_record_object.id} )
    )
  end

  let(:active_record_object) { ContextModule.create!(context: course) }
  let(:noun) { PipelineService::Models::Noun.new(active_record_object)}

  it 'Calls the api' do
    expect(PipelineService::HTTPClient).to receive(:get)
      .with("http://#{ENV['CANVAS_DOMAIN']}:80/api/v1/courses/#{course.id}/modules/#{noun.id}", any_args)
    expect(subject.call).to include( { 'id' => active_record_object.id } )
  end
end
