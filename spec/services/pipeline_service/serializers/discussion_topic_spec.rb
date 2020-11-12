describe PipelineService::Serializers::DiscussionTopic do
  include_context 'stubbed_network'
  subject { described_class.new(object: noun) }

  let(:noun) { PipelineService::Models::Noun.new(discussion_topic) }
  let(:course) { Course.create }
  let(:discussion_topic) { DiscussionTopic.create(context_type: 'course', context: course) }

  it 'gets api json' do
    expect(subject.call).to include( { 'id' => discussion_topic.id } )
  end

end
