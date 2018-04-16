describe PipelineService::Endpoints::Pipeline do
  let(:object) { double('object') }
  let(:http_client) { double('http_client', messages_post: nil) }
  subject { described_class.new(object, 'ARRecord', 1, http_client: http_client) }

  it 'works' do
    subject.call
  end
end
