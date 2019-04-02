describe SettingsService::Base do
  subject {
    described_class.new
  }

  context '#dynamodb' do
    it 'is an instance method not a class method' do
      expect(subject.dynamodb).to be_a(Aws::DynamoDB::Client)

      expect {
        SettingsService::Base.dynamodb
      }.to raise_error(NoMethodError)
    end
  end
end