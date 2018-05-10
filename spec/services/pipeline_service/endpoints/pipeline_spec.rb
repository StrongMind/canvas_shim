describe PipelineService::Endpoints::Pipeline do
  let(:message) { { noun: 'ARRecord', id: 1 } }
  let(:http_client) { double('http_client', messages_post: nil) }
  let(:serializer) {double('serializer class', new: double('serializer instance', call: nil))}
  subject { described_class.new(message: message, args: { http_client: http_client }) }

  before do
    ENV['PIPELINE_ENDPOINT'] = 'https://example.com'
    ENV['PIPELINE_USER_NAME'] = 'example_user'
    ENV['PIPELINE_PASSWORD'] = 'example_password'
    ENV['CANVAS_DOMAIN'] = 'someschool.com'
  end

  it 'works' do
    subject.call
  end
end
