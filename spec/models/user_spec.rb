describe User do
  let(:subject) { User.create }
  let(:enrollment) { double('enrollment') }
  let(:enrollments) { double('enrollments', where: [enrollment])}
  let(:response) { double('response', body: 'im the body') }

  before do
    ENV['TOPIC_MICROSERVICE_ENDPOINT'] = 'endpoint'
    ENV['TOPIC_MICROSERVICE_API_KEY'] = 'key'
    allow(subject).to receive(:enrollments).and_return(enrollments)
  end

  describe '#get_teacher_unread_discussion_topics' do
    it 'is mixed in' do
      expect(subject).to respond_to(:get_teacher_unread_discussion_topics)
    end

    it 'calls the endpoint' do
      expect(HTTParty).to receive(:get).and_return(response)
      subject.get_teacher_unread_discussion_topics
    end

    context "missing configuration" do
      let(:enrollments) { double('enrollments', where: [])}

      before do
        ENV['TOPIC_MICROSERVICE_ENDPOINT'] = nil
        ENV['TOPIC_MICROSERVICE_API_KEY'] = nil
        allow(subject).to receive(:enrollments).and_return(enrollments)
      end

      it 'wont look up enrollments' do
        expect(enrollments).to_not receive(:where)
        subject.get_teacher_unread_discussion_topics
      end

      it "wont call the service" do
        expect(HTTParty).to_not receive(:get)
        subject.get_teacher_unread_discussion_topics
      end
    end
  end
end