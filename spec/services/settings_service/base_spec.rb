describe SettingsService::Base do
  subject {
    described_class.new
  }

  before do
    # to pass TravisCI
    stub_request(:get, /latest\/meta-data\/iam\/security-credentials/).
      with(
       headers: {
      'Accept'=>'*/*',
      'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
      'User-Agent'=>'aws-sdk-ruby3/3.48.2'
    }).to_return(status: 200, body: "", headers: {})

  end

  context '#dynamodb' do
    it 'is an instance method not a class method' do
      expect(subject.dynamodb).to be_a(Aws::DynamoDB::Client)

      expect {
        SettingsService::Base.dynamodb
      }.to raise_error(NoMethodError)
    end
  end
end