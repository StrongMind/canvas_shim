describe PipelineService::Serializers::Unassigned do
    include_context 'stubbed_network'

    let(:assignment) { Assignment.create(course: Course.new) }
    let(:assignment_override) { AssignmentOverride.create() }
    let(:student_1) { User.create() }
    let(:student_2) { User.create() }
    let!(:assignment_override_student_1) {AssignmentOverrideStudent.create(user_id: student_1.id, assignment_id: assignment.id, assignment_override_id: assignment_override.id)}
    let!(:assignment_override_student_2) {AssignmentOverrideStudent.create(user_id: student_2.id, assignment_id: assignment.id, assignment_override_id: assignment_override.id)}
    
    subject { described_class.new(object: PipelineService::Models::Noun.new(assignment)) }

    before do
        allow(::Assignment).to receive(:find).and_return(assignment)
        allow(SettingsService).to receive(:get_settings).and_return({"unassigned_students"=>"#{student_1.id},#{student_2.id}"})
    end

    it 'returns an unassigned object with things' do
        result = subject.call
        expect(result).to eq("{\"assignment_id\":#{assignment.id},\"unassigned_students\":[{\"student_id\":#{student_1.id},\"unassigned_at\":\"#{assignment_override_student_1.created_at.iso8601}\"},{\"student_id\":#{student_2.id},\"unassigned_at\":\"#{assignment_override_student_2.created_at.iso8601}\"}]}")
    end
end
