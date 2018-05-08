describe PipelineService::Serializers::Hash do
  let(:my_hash) { {} }
  subject { described_class.new(object: my_hash) }

  it 'returns the object unchanged' do
    expect(subject.call).to eq my_hash
  end
end
