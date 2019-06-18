describe AlertsService::Client do
  subject { described_class }

  let(:alert) { double('alert', as_json: {teacher_id: 1, student_id: 1, assignment_id: 1, type: 'max_attempts_reached'}) }
  let(:http_client) { double('http_client', post: nil) }
  
  before do
    allow(subject.instance).to receive(:school).and_return(AlertsService::School.new('myschool'))
  end

  describe '#show' do
    it 'returns a client response on success' do
      VCR.use_cassette 'alerts_service/client/show' do
        expect(subject.show(2)).to be_a(AlertsService::Response)
      end
    end

    it 'has a success code' do
      VCR.use_cassette 'alerts_service/client/show' do
        expect(subject.show(2).code).to eq(200)
      end
    end

    it 'has an alert in the payload' do
      VCR.use_cassette 'alerts_service/client/show' do
        expect(subject.show(2).payload).to be_a(AlertsService::Alerts::MaxAttemptsReached)
      end
    end
  end

  describe '#list' do
    it 'has a success code' do
      VCR.use_cassette 'alerts_service/client/list' do
        expect(subject.list(1).code).to eq 200
      end
    end

    it 'has a list of alerts in the payload' do
      VCR.use_cassette 'alerts_service/client/list' do
        expect(subject.list(1).payload.first).to be_a(AlertsService::Alerts::MaxAttemptsReached)
      end
    end
  end

  describe '#create' do
    it 'can create' do
      VCR.use_cassette 'alerts_service/client/create' do
        expect(subject.create(alert).payload).to be_nil
      end
    end

    it 'response code' do
      VCR.use_cassette 'alerts_service/client/create' do
        expect(subject.create(alert).code).to eq(201)
      end
    end
  end

  describe '#destroy' do
    it 'can destroy' do
      VCR.use_cassette 'alerts_service/client/destroy' do
        expect(subject.destroy(2).payload).to be_nil
      end
    end

    it 'can destroy' do
      VCR.use_cassette 'alerts_service/client/destroy' do
        expect(subject.destroy(2).code).to eq 201
      end
    end
  end
end