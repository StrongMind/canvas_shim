describe PipelineService::Serializers::Fetcher do
  subject { described_class }
  let(:object) { double('object', class: 'Assignment') }

  describe '#fetch' do
    it 'fetches serializers based on the object #class' do
      expect(subject.fetch(object: object)).to eq(
        PipelineService::Serializers::Assignment
      )
    end
  end
end
