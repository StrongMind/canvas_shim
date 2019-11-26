describe PipelineService::Serializers::Unassigned do
    include_context 'stubbed_network'

    let(:assignment) { Assignment.create(course: Course.new) }
    let(:student_1) { User.create() }
    let(:student_2) { User.create() }
    
    subject { described_class.new(object: PipelineService::Models::Noun.new(assignment)) }

    before do
        allow(::Assignment).to receive(:find).and_return(assignment)
        allow(SettingsService).to receive(:get_settings).and_return({"unassigned_students"=>"#{student_1.id},#{student_2.id}"})
    end

    it 'returns an unassigned object with things' do
        result = subject.call
        expect(result).to eq("{\"assignment_id\":#{assignment.id},\"unassigned_students\":[#{student_1.id},#{student_2.id}]}")
    end
end
