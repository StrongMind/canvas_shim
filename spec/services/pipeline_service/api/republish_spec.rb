describe PipelineService::API::Republish do
  include_context "pipeline_context"
  subject do 
    described_class.new(
      PipelineService::Nouns::UnitGrades, 
      range: 3.days.ago...DateTime.now
    )
  end
  
  let(:submission) do
    double(
      "submission",
      user: double('user'),
      id: 1,
      assignment: double('assignment', 
        course: double('course')
      ),
      changes: {}
    )
  end

  let(:unit_grades) { double('unit_grades') }
  
  before do
    class_double("Submission", where: [submission]).as_stubbed_const
    class_double("PipelineService::Nouns::UnitGrades", new: unit_grades).as_stubbed_const
  end

  describe '#call' do
    it 'publishes records' do
      expect(PipelineService).to receive(:publish).with(submission)
      subject.call
    end

    context 'when publishing a submission' do
      it 'also publishes unit grades' do
        expect(PipelineService).to receive(:publish).with(unit_grades)
        subject.call
      end
    end
  end
end