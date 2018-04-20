describe PipelineService::Endpoints::SIS do
  let(:message) { {noun: 'student_enrollment', id: 1, data: {state: 'completed'} } }
  let(:http_client) { double("HTTPClient") }


  before do
    ENV['SIS_ENROLLMENT_UPDATE_API_KEY'] = 'key'
    ENV['SIS_ENROLLMENT_UPDATE_ENDPOINT'] = 'endpoint'
  end

  describe '#call' do
    subject { described_class.new(message: message, args: { http_client: http_client }) }
    it 'will post student enrollments' do
      expect(http_client).to receive(:post)
      subject.call
    end

    context 'filtered' do
      let(:message) { { noun: 'teacher_enrollment', id: 1, data: { state: 'completed' } } }
      subject { described_class.new(message: message, args: { http_client: http_client }) }
      it 'will only post student enrollments' do
        expect(http_client).to_not receive(:post)
        subject.call
      end
    end
  end
end
