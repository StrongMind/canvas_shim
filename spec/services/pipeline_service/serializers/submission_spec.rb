describe PipelineService::Serializers::Submission do
  let (:user)       { double('user') }
  let (:submission) { double('submission') }
  subject           { described_class.new(object: submission) }

  before do
    allow(PipelineService::Account).to receive(:account_admin).and_return(user)
  end

  describe 'Stubbed methods to work with Canvas' do
    it '#params = {}' do
      expect(subject.params).to eq({})
    end

    it '#host_with_port' do
      expect(subject.request.host_with_port).to eq 'someschool.com:80'
    end

    describe '#request' do
      it '#ssl?' do
        expect(subject.request.ssl?).to eq false
      end

      it '#protocol' do
        expect(subject.request.protocol).to eq "http://"
      end

      it '#host' do
        expect(subject.request.host).to eq "someschool.com"
      end

      it '#port' do
        expect(subject.request.port).to eq 80
      end
    end

  end
end
