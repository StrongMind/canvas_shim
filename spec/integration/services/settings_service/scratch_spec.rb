require 'pp'
require 'aws-sdk'
require 'byebug'

describe do
  let(:table_name) {'EnrollmentSettings'}
  let(:dynamodb) {Aws::DynamoDB::Client.new}
  before do
    creds = Aws::Credentials.new('ACCESS_KEY', 'ACCESS_KEY_ID')
    Aws.config.update({
      region: 'us-west-2',
      credentials: creds
    })
  end

  xit 'query' do
    params = {
      table_name: table_name,
      key_condition_expression: "#id = :value",
      expression_attribute_names: {
          "#id" => "id"
      },
      expression_attribute_values: {
          ":value" => 1
      }
    }
    pp dynamodb.query(params)
  end

  it 'get an item' do
    key = {
        id: 1,
        setting: 'foo'
    }

    params = {
        table_name: table_name,
        key: key
    }

    result = dynamodb.get_item(params)
    puts result
  end

  xit 'create an item' do
    setting = {
      id: 1,
      setting: 'foofoo',
      value: 'barbar'
    }

    params = {
      table_name: table_name,
      item: setting
    }

    dynamodb.put_item(params)
  end

  xit 'Create a table' do
    params = {
      table_name: table_name,
      key_schema: [
          {
              attribute_name: 'id',
              key_type: 'HASH'  #Partition key
          },
          {
              attribute_name: 'setting',
              key_type: 'RANGE' #Sort key
          },
      ],
      attribute_definitions: [
          {
              attribute_name: 'id',
              attribute_type: 'N'
          },
          {
              attribute_name: 'setting',
              attribute_type: 'S'
          },
      ],
      provisioned_throughput: {
          read_capacity_units: 10,
          write_capacity_units: 10
      }
    }


    result = dynamodb.create_table(params)

    byebug
  end
end
