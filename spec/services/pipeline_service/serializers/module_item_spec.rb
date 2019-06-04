describe PipelineService::Serializers::ModuleItem do
  include_context('stubbed_network')
  subject { described_class.new(object: noun) }
  let(:context_module) { ContextModule.create }
  let(:course) { Course.create }
  let(:content_tag) { ContentTag.create(context_module: context_module, context: course) }
  let(:noun) { PipelineService::Nouns::ModuleItem.new(content_tag) }

  it do
    expect(PipelineService::HTTPClient).to receive(:get).with(
      "http://#{ENV['CANVAS_DOMAIN']}:80/api/v1/courses/#{course.id}/modules/#{context_module.id}/items/#{content_tag.id}",
      any_args
    )
    subject.call
  end
end
