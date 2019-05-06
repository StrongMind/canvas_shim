describe PipelineService::Serializers::Course do
    include_context "stubbed_network"
  
    subject { described_class.new(object: noun) }
  
    let(:active_record_object) { Course.create!() }
    let(:noun) { PipelineService::Models::Noun.new(active_record_object)}
  
    it 'Return an attribute hash of the noun' do
      expect(subject.call).to include( { noun.primary_key => active_record_object.id } )
    end
  end