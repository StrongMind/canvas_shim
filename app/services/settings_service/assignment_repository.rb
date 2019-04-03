require 'forwardable'
module SettingsService
  class AssignmentRepository < RepositoryBase
    def get(table_name:, id:)
      dynamodb.query(
        table_name: table_name,
        key_condition_expression: "#id = :id",
        expression_attribute_names: { "#id" => "id" },
        expression_attribute_values: { ":id" => id }
      ).items.inject({}) do |newhash, setting|
        newhash[setting['setting']] = setting['value']
        newhash
      end
    end

    def put(table_name:, id:, setting:, value:)
      dynamodb.put_item(
        table_name: table_name,
        item: {
          id: id,
          setting: setting,
          value: value
        }
      )
    end

    private

    def table_params(name)
      {
        table_name: name,
        key_schema: [
          { attribute_name: 'id', key_type: 'HASH' },
          { attribute_name: 'setting', key_type: 'RANGE'},
        ],
        attribute_definitions: [
            { attribute_name: 'id', attribute_type: 'S' },
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
