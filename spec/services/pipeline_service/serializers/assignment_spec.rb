module PipelineService
    describe Serializers::Assignment do
        let(:assignment) { Assignment.new(course: Course.new) }
        subject { described_class.new(object: Models::Noun.new(assignment)) }

        before do
            allow(::Assignment).to receive(:find).and_return(assignment)
        end

        it '#additional_identifier_fields' do
            expect(described_class.additional_identifier_fields).to eq [:course_id]
        end
    end
end