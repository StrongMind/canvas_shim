describe PipelineService::V2::Payload do
  it 'does not log' do
    expect(Logger).to_not receive(:new)
    described_class.new(object: PipelineService::V2::Noun.new(
      PageView.new)).call
  end
end