module SettingsService
  class Base
    def dynamodb
      @dynamodb || Aws::DynamoDB::Client.new
    end
  end
end