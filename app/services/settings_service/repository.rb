module SettingsService
  class Repository
    include Singleton

    def initialize
      @secret_key = ENV['AWS_SECRET_ACCESS_KEY']
      @id_key = ENV['AWS_ACCESS_KEY_ID']

      Aws.config.update({
        region: 'us-west-2',
        credentials: creds
      })
    end

    def self.create_table(name:)
      instance.create_table(name: name)
    end

    def create_table(name:)
      dynamodb.create_table(table_params(name)).successful?
    end

    private

    def dynamodb
      Aws::DynamoDB::Client.new
    end

    def creds
      Aws::Credentials.new(@id_key, @secret_key)
    end

    def table_params(name)
      {
        table_name: name,
        key_schema: [
          { attribute_name: 'id', key_type: 'HASH' },
          { attribute_name: 'setting', key_type: 'RANGE'},
        ],
        attribute_definitions: [
            { attribute_name: 'id', attribute_type: 'N' },
            { attribute_name: 'setting', attribute_type: 'S' },
        ],
        provisioned_throughput: {
            read_capacity_units: 10,
            write_capacity_units: 10
        }
      }
    end

  end
end
