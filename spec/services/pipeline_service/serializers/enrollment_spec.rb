describe PipelineService::Serializers::Enrollment do
    describe '#additional_identifier_fields' do
         it 'has a course_id and an user_id' do 
            expect(described_class.additional_identifier_fields).to eq [:course_id, :user_id]
         end
    end
end