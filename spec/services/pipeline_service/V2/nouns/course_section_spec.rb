describe PipelineService::V2::Nouns::CourseSection do
  include_context "stubbed_network"

  subject { described_class.new(object: noun) }

  let(:active_record_object) { ::CourseSection.create }

  let(:noun) { PipelineService::V2::Noun.new(active_record_object)}

  describe '#call'do
    it '' do
      expect(subject.call).to include({"id" => active_record_object.id })
    end
  end
end
