module SettingsService
  class RepositoryBase
    include Singleton

    def initialize
      raise "missing settings table prefix!" if SettingsService.settings_table_prefix.nil?
      @secret_key = ENV['S3_ACCESS_KEY']
      @id_key = ENV['S3_ACCESS_KEY_ID']
      Aws.config.update(
        region: ENV['AWS_REGION'],
        credentials: creds
      )
    end

    def creds
      Aws::Credentials.new(@id_key, @secret_key)
    end

    class << self
      extend Forwardable
      def_delegators :instance, :create_table, :get, :put
    end

    def create_table(name:)
      begin
        dynamodb.create_table(table_params(name)).successful?
        dynamodb.wait_until(:table_exists, {table_name: name})
      rescue
      end
    end

    def dynamodb
      @dynamodb ||= Rails.env.development? ? Aws::DynamoDB::Client.new(:endpoint => "http://localhost:8000/") : Aws::DynamoDB::Client.new
    end
  end
end
