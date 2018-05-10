describe PipelineService::Serializers::Fetcher do
  subject { described_class }
  let(:object) { double('object', class: 'Assignment') }

  describe '#fetch' do
    it 'fetches serializers based on the object #class' do
      expect(subject.fetch(object: object)).to eq(
        PipelineService::Serializers::Assignment
      )
    end

    it 'fetches the Hash serializer if the object is a hash' do
      expect(subject.fetch(object: {})).to eq(
        PipelineService::Serializers::Hash
      )
    end
  end
end
