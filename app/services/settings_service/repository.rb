require 'forwardable'
module SettingsService
  class Repository
    include Singleton

    class << self
      extend Forwardable
      def_delegators :instance, :create_table, :get, :put
    end

    def initialize
      raise "missing canvas domain!" if SettingsService::Enrollment.canvas_domain.nil?
      @secret_key = ENV['S3_ACCESS_KEY']
      @id_key = ENV['S3_ACCESS_KEY_ID']
      Aws.config.update(
        region: 'us-west-2',
        credentials: creds
      )
    end

    def create_table(name:)

      begin
        dynamodb.create_table(table_params(name)).successful?
      rescue
      end
    end

    def get(table_name:, id:)
      dynamodb.query(
        table_name: table_name,
        key_condition_expression: "#id = :id",
        expression_attribute_names: { "#id" => "id" },
        expression_attribute_values: { ":id" => id.to_i }
      ).items.inject({}) do |newhash, setting|
        newhash[setting['setting']] = setting['value']
        newhash
      end
    end

    def put(table_name:, id:, setting:, value:)
      dynamodb.put_item(
        table_name: table_name,
        item: {
          id: id.to_i,
          setting: setting,
          value: value
        }
      )
    end

    def self.use_test_client!
      instance.use_test_client!
    end

    def use_test_client!
      @dynamodb = Aws::DynamoDB::Client.new(endpoint: 'http://localhost:8000')
    end

    private

    def dynamodb
      @dynamodb || Aws::DynamoDB::Client.new
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
