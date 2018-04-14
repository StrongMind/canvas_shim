describe PipelineService::Endpoints::SIS do
  let(:message) { { noun: 'StudentEnrollment' } }
  let(:http_client) { double("HTTPClient") }
  subject { described_class.new(message, http_client: http_client) }

  before do
    ENV['SIS_ENROLLMENT_UPDATE_API_KEY'] = 'key'
    ENV['SIS_ENROLLMENT_UPDATE_ENDPOINT'] = 'endpoint'
  end

  describe '#call' do
    it 'will post student enrollments' do
      expect(http_client).to receive(:post)
      subject.call
    end

    context 'filtered' do
      let(:message) { { noun: 'TeacherEnrollment' } }
      it 'will only post student enrollments' do
        expect(http_client).to_not receive(:post)
        subject.call
      end
    end
  end
end
