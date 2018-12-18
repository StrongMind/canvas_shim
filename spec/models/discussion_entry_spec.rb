describe DiscussionEntry do
  describe '#set_unread_status' do
    let(:course) { Course.create }
    let(:discussion_topic) { DiscussionTopic.create(context: course) }
    let(:teacher) { User.create }

    before do
      allow(ENV).to receive(:[]).with('TOPIC_MICROSERVICE_DOMAIN').and_return "endpoint"
      allow(ENV).to receive(:[]).with('TOPIC_MICROSERVICE_API_KEY').and_return "key"
      allow(course).to receive(:teachers).and_return([teacher])
    end

    subject do
      DiscussionEntry.create(discussion_topic: discussion_topic)
    end

    context "unread" do
      it 'requires an endpoint' do
        expect(HTTParty).to receive(:post)
        subject
      end
    end

    context "missing configuration" do
      before do
        allow(ENV).to receive(:[]).with('TOPIC_MICROSERVICE_DOMAIN').and_return nil
        allow(ENV).to receive(:[]).with('TOPIC_MICROSERVICE_API_KEY').and_return nil
      end

      it 'requires an endpoint' do
        expect(course).to_not receive(:teachers)
        subject
      end
    end
  end
end
