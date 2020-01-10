describe DiscussionEntry do
  include_context "stubbed_network"

  describe '#set_unread_status' do
    let(:course) { Course.create(users: [teacher]) }
    let(:discussion_topic) { DiscussionTopic.create(context: course) }
    let(:teacher) { User.create }

    let(:endpoint) do
      "endpoint/teachers/#{ENV['CANVAS_DOMAIN']}:#{teacher.id}/topics/#{discussion_topic.id}"
    end

    let(:headers) { { :"x-api-key"=>'key' } }

    before do
      ENV['TOPIC_MICROSERVICE_ENDPOINT'] = 'endpoint'
      ENV['TOPIC_MICROSERVICE_API_KEY'] = 'key'
      ENV['CANVAS_DOMAIN'] = 'test'

      allow(HTTParty).to receive(:post)
      allow(HTTParty).to receive(:delete)
      allow(SettingsService).to receive(:get_settings).and_return('show_unread_discussions' => true)

      DiscussionEntry.create(discussion_topic: discussion_topic, unread: true, user_id: teacher.id)

    end

    subject do
      DiscussionEntry.create(discussion_topic: discussion_topic, unread: true, user_id: teacher.id)
    end

    context 'when the entry has not been read' do
      it 'posts to the endpoint on save' do
        expect(HTTParty).to receive(:post).with(endpoint, headers: headers)
        subject.save
      end
    end

    context 'when the entry has been read' do
      subject do
        DiscussionEntry.create(discussion_topic: discussion_topic, unread: false, user_id: teacher.id)
      end

      it 'delete to the endpoint on save' do
        expect(HTTParty).to receive(:delete).with(endpoint, headers: headers)
        subject.save
      end

      it 'delete to the endpoint on find' do
        expect(HTTParty).to receive(:delete)
        result = described_class.find(subject.id)
      end
    end

    context 'when the configuration is missing' do
      before do
        ENV['TOPIC_MICROSERVICE_ENDPOINT'] = nil
        ENV['TOPIC_MICROSERVICE_API_KEY'] = nil
      end

      it 'wont post to the service' do
        expect(HTTParty).to_not receive(:delete)
        expect(HTTParty).to_not receive(:post)
        subject
      end
    end

    context 'when unread discussion feature flag is off' do
      before do
        allow(SettingsService).to receive(:get_settings).and_return('show_unread_discussions' => false)
      end

      it 'wont post to the service' do
        expect(HTTParty).to_not receive(:delete)
        expect(HTTParty).to_not receive(:post)
        subject
      end
    end
  end
end
