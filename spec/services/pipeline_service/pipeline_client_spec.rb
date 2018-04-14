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
end
