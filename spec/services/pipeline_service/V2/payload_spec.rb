describe PipelineService::V2::Payload do
  it 'does not log' do
    expect(Logger).to_not receive(:new)
    described_class.new(object: PipelineService::V2::Noun.new(
      PageView.new)).call
  end

  it 'adds additional identifiers to submissions' do
    res = described_class.new(object: PipelineService::V2::Noun.new(
      Submission.new)).call
    expect(res[:identifiers]).to eq ({
        :assignment_id => nil,
        :course_id => nil,
        :id => nil,
      })
  end
end
