describe AlertsService::Client do
  subject { described_class }

  let(:alert) { double('alert') }
  let(:http_client) { double('http_client', post: nil) }
  
  before do
    allow(subject.instance).to receive(:school).and_return(AlertsService::Client::School.new('myschool'))
  end

  describe '#show' do
    it 'returns a client response on success' do
      VCR.use_cassette 'alerts_service/client/show' do
        expect(subject.show(1)).to be_a(AlertsService::Client::Response)
      end
    end

    it 'has a success code' do
      VCR.use_cassette 'alerts_service/client/show' do
        expect(subject.show(1).code).to eq(200)
      end
    end

    it 'has an alert in the payload' do
      VCR.use_cassette 'alerts_service/client/show' do
        expect(subject.show(1).payload).to be_a(AlertsService::Alerts::MaxAttemptsReached)
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
    it do
      VCR.use_cassette 'alerts_service/client/create' do
        expect(subject.create(alert)).to eq 200
      end
    end
  end

  describe '#destroy' do
    it do
      VCR.use_cassette 'alerts_service/client/destroy' do
        expect(subject.destroy(1)).to eq 200
      end
    end
  end
end