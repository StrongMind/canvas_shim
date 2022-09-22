describe DiscussionEntry do
  include_context "stubbed_network"

  describe '#set_unread_status' do
    let(:course) { Course.create(users: [teacher, student]) }
    let(:discussion_topic) { DiscussionTopic.create(context: course) }
    let(:teacher) { User.create }
    let(:student) { User.create }

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

  describe "#is_discussion_reply_from_student?" do
    let(:course) { Course.create(users: [teacher, student]) }
    let(:discussion_topic) { DiscussionTopic.create(context: course) }
    let(:teacher) { User.create }
    let(:student) { User.create }

    before do
      allow(SettingsService).to receive(:get_settings).and_return('reply_alerts' => true)
    end

    context 'Student Discussion Entry' do
      subject do
        DiscussionEntry.create(discussion_topic: discussion_topic, unread: false, user_id: student.id)
      end

      before do
        allow(subject.user).to receive(:student_enrollments).and_return(student.enrollments)
      end

      context "Root Entry" do
        before do
          allow(subject).to receive(:parent_id).and_return(nil)
        end

        it "returns false if root entry" do
          expect(subject.send(:is_discussion_reply_from_student?)).to be_falsy
        end
      end

      context "Second root Entry" do
        it "returns true if second root entry" do
          # Arrange
          student = User.create
          DiscussionEntry.create(discussion_topic: discussion_topic, unread: false, user_id: student.id, parent_id: nil)
          Enrollment.create(course_id: course.id, user_id: student.id, type: "StudentEnrollment")
          allow(student).to receive(:student_enrollments).and_return(student.enrollments)
          second_entry = DiscussionEntry.create(discussion_topic: discussion_topic, unread: false, user_id: student.id, parent_id: nil)
          allow(SettingsService).to receive(:get_settings).and_return('reply_alerts' => true)
          # Act
          result = second_entry.send(:is_discussion_reply_from_student?)
          # Assert
          expect(result).to be_truthy
        end
      end

      context "Non-root Entry" do
        before do
          allow(subject).to receive(:parent_id).and_return(subject.id)
        end

        it "returns true if reply" do
          expect(subject.send(:is_discussion_reply_from_student?)).to be_truthy
        end
      end
    end

    context 'Teacher Discussion Entry' do
      subject do
        DiscussionEntry.create(discussion_topic: discussion_topic, unread: false, user_id: teacher.id)
      end

      context "Root Entry" do
        before do
          allow(subject).to receive(:parent_id).and_return(nil)
        end

        it "returns false if teacher (root entry)" do
          expect(subject.send(:is_discussion_reply_from_student?)).to be_falsy
        end
      end

      context "Non-root Entry" do
        before do
          allow(subject).to receive(:parent_id).and_return(subject.id)
        end

        it "returns false if teacher (reply)" do
          expect(subject.send(:is_discussion_reply_from_student?)).to be_falsy
        end
      end
    end
  end
end
