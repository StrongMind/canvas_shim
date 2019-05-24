describe PipelineService::Serializers::DiscussionTopic do
  subject { described_class.new(object: noun) }

  let(:noun) { PipelineService::Models::Noun.new(discussion_topic) }
  let(:course) { Course.create }
  let(:discussion_topic) { DiscussionTopic.create(context_type: 'course', context: course) }

  before do
    allow(PipelineService::HTTPClient).to receive(:post)
    allow(SettingsService).to receive(:get_settings).and_return({})
    allow(HTTParty).to receive(:post)
    allow(PipelineService::HTTPClient).to receive(:get).and_return(double('response', parsed_response: {}))
  end

  it 'calls our api with course and discussion_topic ids' do
    expect(PipelineService::HTTPClient).to receive(:get)
      .with("http://#{ENV['CANVAS_DOMAIN']}:80/api/v1/courses/#{course.id}/discussion_topics/#{discussion_topic.id}", any_args)
      .and_return(double('response', parsed_response: {}))

    subject.call
  end

end
