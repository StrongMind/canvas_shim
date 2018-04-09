describe PipelineService::PipelineClient do
  subject do
    described_class.new(
      message_api: api,
      sis_endpoint: sis_endpoint_class
    )
  end

  describe '#call' do
    let(:api) { double('api', messages_post: nil) }
    let(:sis_endpoint_class) do
      double('endpoint_class')
    end
    let(:sis_endpoint_instance) do
      double('endpoint_instance', call: nil)
    end

    before do
      ENV['PIPELINE_ENDPOINT'] = 'https://example.com'
      ENV['PIPELINE_USER_NAME'] = 'example_user'
      ENV['PIPELINE_PASSWORD'] = 'example_password'
      ENV['CANVAS_DOMAIN'] = 'someschool.com'
    end

    it 'works' do
      expect(sis_endpoint_class).to(receive(:new)).and_return(sis_endpoint_instance)
      subject.call
    end
  end
end
