describe PipelineService::API::Republish do
  include_context "pipeline_context"
  subject do 
    described_class.new(
      model: PipelineService::Nouns::UnitGrades, 
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
    it 'publishes specific records' do
      expect(PipelineService).to receive(:publish).with(submission)
      subject.call
    end

    context 'when missing a range' do
      subject do 
        described_class.new(model: PipelineService::Nouns::UnitGrades)
      end
    
      it 'requires a range' do
        expect{subject.call}.to raise_error("Missing required date range")
      end  
    end

    context 'when no model specified' do
      subject do
        described_class.new(range: 3.days.ago...DateTime.now)
      end

      before do
        class_double('::Assignment', where: []).as_stubbed_const
        class_double('::ConversationMessage', where: []).as_stubbed_const
        class_double('::ConversationParticipant', where: []).as_stubbed_const
        class_double('::Conversation', where: []).as_stubbed_const
        class_double('::Enrollment', where: []).as_stubbed_const
        class_double('::Submission', where: []).as_stubbed_const
        class_double('::User', where: []).as_stubbed_const
      end
      
      it 'publishes all records' do
        PipelineService::API::Republish.models.each do |model_class|
          expect(model_class).to receive(:where)
        end
        subject.call
      end
    end

    context 'when publishing a submission' do
      it 'also publishes unit grades' do
        expect(PipelineService).to receive(:publish).with(unit_grades)
        subject.call
      end
    end
  end
end