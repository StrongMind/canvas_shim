
describe PipelineService::Nouns::Submission do
    include_context 'pipeline_context'

    let(:submission) do 
        ::Submission.create(
            assignment: ::Assignment.create(course: Course.create), 
            user: User.create) 
    end

    subject { described_class.new(ar_submission: submission) }

    describe '#as_json' do
        it do
            expect(subject.as_json).to eq({})
        end
    end
    
    describe 'can be built' do
        it do
            PipelineService::Nouns::Base.build(submission)
        end
    end
end