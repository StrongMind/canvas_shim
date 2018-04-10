describe PipelineService::PipelineClient do
  let(:message_api) { double('message_api', messages_post: nil) }

  subject do
    described_class.new(
      object: nil,
      noun_name: '',
      id: 1,
      message_api: message_api
    )
  end

  it 'posts to the pipeline library' do
    expect(message_api).to receive(:messages_post).and_return(nil)
    subject.call
  end
end
