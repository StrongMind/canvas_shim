describe PipelineService::V2::Nouns::Submission do
    include_context "stubbed_network"
  
    subject { described_class.new(object: noun) }
  
    let(:active_record_object) { ::Submission.create!(assignment: Assignment.create!(course: Course.create)) }
  
    let(:noun) { PipelineService::V2::Noun.new(active_record_object)}
  
    describe '#call'do
      it 'calls the canvas json method for submission' do
        expect(subject).to receive(:submission_json)
        subject.call
      end
    end    
  end
  