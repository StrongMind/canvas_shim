describe PipelineService::V2::Noun do
  describe '#ar_model' do
    let(:ar_model) { PageView.new }
    subject { described_class.new(ar_model) }

    it 'returns the model set in the initializer' do
      expect(subject.ar_model).to eq(ar_model)
    end
  end
end