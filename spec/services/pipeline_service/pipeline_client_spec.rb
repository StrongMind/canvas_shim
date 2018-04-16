describe PipelineService::PipelineClient do
  let(:endpoint) { double('endpoint', call: nil) }

  subject do
    described_class.new(
      object: nil,
      noun_name: '',
      id: 1,
      endpoint: endpoint
    )
  end

  it 'posts to the endpoint' do
    expect(endpoint).to receive(:call).and_return(nil)
    subject.call
  end

  context 'defaults' do
    subject do
      described_class.new(
        object: nil,
        noun_name: '',
        id: 1
      )
    end

    it 'defaults to the pipeline endpoint' do
      expect(subject.send(:endpoint).class).to eq PipelineService::Endpoints::Pipeline
    end
  end
end
