describe PipelineService::Nouns::ModuleItem do
  include_context 'stubbed_network'
  let(:course) { Course.create }
  let(:content_tag) { ContentTag.create(context: course, context_module: context_module) }
  let(:context_module) { ContextModule.create }
  subject { described_class.new(content_tag) }

  describe '#course_id' do
    it do
      expect(subject.context_id).to eq(course.id)
    end
  end

  describe '#context_module_id' do
    it do
      expect(subject.context_module_id).to eq(context_module.id)
    end
  end

  describe '#additional_identifers' do
    it 'returns the context_module id' do
      expect(subject.additional_identifiers[:module_id]).to eq context_module.id
    end

    it 'returns the course id' do
      expect(subject.additional_identifiers[:course_id]).to eq course.id
    end
  end

  describe '#id' do
    it do
      expect(subject.id).to eq(content_tag.id)
    end
  end
end
