describe PipelineService::Serializers::Unassigned do
    include_context 'stubbed_network'

    let(:assignment) { Assignment.create(course: Course.new) }
    let(:student_1) { User.create() }
    let(:student_2) { User.create() }

    let(:timestamp) { Time.now }
    
    let(:json_context) do
      {
        timestamp => {
          "grader_id" => 1,
           "unassigns" => [2, 3, 4]
        }
      }.to_json
    end
    
    subject { described_class.new(object: PipelineService::Models::Noun.new(assignment)) }

    before do
      allow(::Assignment).to receive(:find).and_return(assignment)
      allow(SettingsService).to receive(:get_settings).and_return({ "unassign_context" => json_context })
    end

    it 'returns an unassigned object with assignment and unassigned_student ids' do
      result = subject.call
      expect(result).to eq("{\"assignment_id\":#{assignment.id},\"unassigned_students\":{\"#{timestamp}\":{\"grader_id\":1,\"unassigns\":[2,3,4]}}}")
    end
end
