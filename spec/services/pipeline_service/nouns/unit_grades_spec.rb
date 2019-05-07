describe PipelineService::Nouns::UnitGrades do
  describe '.primary_key' do
    it 'has a primary key' do
      expect(described_class.primary_key).to eq('id')
    end
  end
end
