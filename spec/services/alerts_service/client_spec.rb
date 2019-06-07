describe AlertsService::Client do
  subject { described_class }

  let(:alert) { double('alert') }
  let(:http_client) { double('http_client', post: nil) }
  
  before do
    allow(subject.instance).to receive('school_name').and_return('myschool')
  end

  describe '#get'
  describe '#list'
  describe '#create' do
    it do
      VCR.use_cassette 'alerts_service/client/create' do
        subject.create(alert)
      end
    end
  end
  describe '#destroy'
end