describe PipelineService do
  describe '#publish' do
    let(:submission) { Submission.create }
    before do
      
    end
    it 'is callable' do
      PipelineService.publish(submission)
    end
  end
end
