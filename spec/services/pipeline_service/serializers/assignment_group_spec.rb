describe PipelineService::Serializers::AssignmentGroup do
    include_context "stubbed_network"

    subject { described_class.new(object: noun) }

    let(:active_record_object) { AssignmentGroup.create!() }
    let(:noun) { PipelineService::Models::Noun.new(active_record_object)}

    it 'Return an attribute hash of the noun' do
      expect(subject.call).to include( { noun.primary_key => active_record_object.id } )
    end

    it '#additional_identifier_fields' do
        expect(described_class.additional_identifier_fields.map(&:to_h)).to eq [{:context_id=>:course_id}]
    end
  end
