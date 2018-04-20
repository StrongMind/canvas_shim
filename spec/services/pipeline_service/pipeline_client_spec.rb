describe PipelineService::PipelineClient do
  let(:endpoint_instance) { double('endpoint_instance', call: nil)}
  let(:endpoint_class) { double('endpoint_class', new: endpoint_instance) }
  let(:serializer) {double('serializer class', new: double('serializer instance', call: nil))}

  subject do
    described_class.new(
      object: Enrollment.new,
      noun: '',
      id: 1,
      endpoint: endpoint_class
    )
  end

  it 'posts to the endpoint' do
    expect(endpoint_instance).to receive(:call).and_return(nil)
    subject.call
  end

  it 'looks up the serializer' do
    expect(PipelineService::Serializers::Fetcher)
      .to receive(:fetch)
      .and_return(serializer)
    subject.call
  end

  context 'defaults' do
    subject { described_class.new(object: nil, noun: '', id: 1) }

    it 'defaults to the pipeline endpoint' do
      expect(subject.send(:endpoint_class)).to eq PipelineService::Endpoints::Pipeline
    end
  end
end
