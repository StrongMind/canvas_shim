describe Conversation do
  subject { described_class }

  it 'it publishes to the pipeline' do
    expect(PipelineService).to receive(:publish)
    subject.create
  end
end
