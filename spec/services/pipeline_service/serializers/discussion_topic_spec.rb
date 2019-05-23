describe PipelineService::Serializers::DiscussionTopic do
  subject { described_class.new(object: noun) }
  let(:body) do
    {
    "id": 1,
    "title": "Topic 1",
    "message": "<p>content here</p>",
    "html_url": "https://<canvas>/courses/1/discussion_topics/2",
    "posted_at": "2037-07-21T13:29:31Z",
    "last_reply_at": "2037-07-28T19:38:31Z",
    "require_initial_post": false,
    "user_can_see_posts": true,
    "discussion_subentry_count": 0,
    "read_state": "read",
    "unread_count": 0,
    "subscribed": true,
    "subscription_hold": "not_in_group_set",
    "assignment_id": nil,
    "delayed_post_at": nil,
    "published": true,
    "lock_at": nil,
    "locked": false,
    "pinned": false,
    "locked_for_user": true,
    "lock_info": nil,
    "lock_explanation": "This discussion is locked until September 1 at 12:00am",
    "user_name": "User Name",
    "topic_children": [5, 7, 10],
    "group_topic_children": [{"id":5,"group_id":1}, {"id":7,"group_id":5}, {"id":10,"group_id":4}],
    "root_topic_id": nil,
    "podcast_url": "/feeds/topics/1/enrollment_1XAcepje4u228rt4mi7Z1oFbRpn3RAkTzuXIGOPe.rss",
    "discussion_type": "side_comment",
    "group_category_id": nil,
    "attachments": nil,
    "permissions": {"attach":true},
    "allow_rating": true,
    "only_graders_can_rate": true,
    "sort_by_rating": true
  }.to_json
end

  let(:noun) { PipelineService::Models::Noun.new(discussion_topic) }
  let(:course) { Course.create }
  let(:discussion_topic) { DiscussionTopic.create(context_type: 'course', context: course) }

  before do
    allow(SettingsService).to receive(:get_settings).and_return({})
    stub_request(:any, "https://3wupzgqsoh.execute-api.us-west-2.amazonaws.com/prod")
    stub_request(:any, "http://canvasdomain.com:3000/api/v1/courses/#{course.id}/discussion_topics/#{discussion_topic.id}").to_return(body: body)
    stub_request(:post, "http://localhost:8080/messages").
             with(
               body: "{\"noun\":\"course\",\"meta\":{\"source\":\"canvas\",\"domain_name\":\"canvasdomain.com\",\"api_version\":1,\"status\":null},\"identifiers\":{\"id\":#{discussion_topic.id},\"data\":{\"id\":#{discussion_topic.id},\"start_at\":null,\"time_zone\":null,\"end_at\":null,\"conclude_at\":null,\"workflow_state\":null}}",
               headers: {
           	  'Authorization'=>'Basic dXNlcjpwYXNzd29yZA==',
           	  'Content-Type'=>'application/json',
           	  'Expect'=>'',
           	  'User-Agent'=>'Swagger-Codegen/1.0.3/ruby'
               }).
             to_return(status: 200, body: "", headers: {})  end

  it 'returns an attribute hash for the noun' do
    #byebug
    expect(subject.call).to eq(body)
  end

  # it 'returns an empty hash if the conversation can not be found' do
  #   conversation_model.destroy
  #   expect(subject.call).to eq( {} )
  # end
end
