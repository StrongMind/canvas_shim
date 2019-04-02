module SettingsService
  class Base
    def self.use_test_client!
      instance.use_test_client!
    end

    def use_test_client!
      Aws.config = {}
      @dynamodb = Aws::DynamoDB::Client.new(endpoint: 'http://localhost:8000')
    end

    def dynamodb
      @dynamodb || Aws::DynamoDB::Client.new
    end
  end
end